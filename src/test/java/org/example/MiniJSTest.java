package org.example;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.Token;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class MiniJSTest {
    @TempDir Path tempDir;

    private List<Integer> types(String text) {
        return new MiniJS(CharStreams.fromString(text)).getAllTokens()
                .stream().map(Token::getType).toList();
    }

    @ParameterizedTest
    @ValueSource(strings = {"/**/", "/***/", "/****/", "/* ok **/", "/* a\n** b ***/"})
    void closedCommentPreservesFollowingCode(String comment) {
        assertEquals(List.of(MiniJS.BLOCK_COMMENT, MiniJS.LET, MiniJS.IDENTIFIER,
                MiniJS.ASSIGN, MiniJS.INTEGER, MiniJS.SEMI), types(comment + " let x = 1;"));
    }

    @ParameterizedTest
    @ValueSource(strings = {"/*", "/**", "/***", "/* text\n** unfinished", "/* a ** b"})
    void unfinishedCommentIsOneError(String comment) {
        assertEquals(List.of(MiniJS.UNCLOSED_BLOCK_COMMENT), types(comment));
    }

    @ParameterizedTest
    @ValueSource(strings = {"'It\\'s a \"beautiful\" day'", "\"abc\\\ndef\"",
            "\"abc\\\r\ndef\"", "\"\\x41\"", "\"\\q\"",
            "\"\\u0041\"", "\"\\u{1F600}\"", "\"\\0\""})
    void requiredEscapesAndContinuations(String text) {
        assertEquals(List.of(MiniJS.STRING), types(text));
    }

    @ParameterizedTest
    @ValueSource(strings = {"\"\\xZZ\"", "\"\\x1\"", "'\\u12'", "\"\\u{}\"",
            "\"\\u{110000}\"", "\"\\u{FFFFFFFFFFFFFFFF}\"", "\"\\08\""})
    void invalidEscapesAreOneErrorAndRecover(String source) throws Exception {
        assertEquals(List.of(MiniJS.INVALID_STRING, MiniJS.SEMI, MiniJS.LET,
                MiniJS.IDENTIFIER, MiniJS.ASSIGN, MiniJS.INTEGER), types(source + "; let x=1"));
        assertTrue(report(source).contains("--- Lexical Errors: 1 ---"));
        assertEquals(MiniJS.INVALID_STRING, types("`${" + source + "}`").get(2));
        assertEquals(MiniJS.INVALID_STRING, types("`${{" + source + "}}`").get(3));
    }

    @ParameterizedTest
    @ValueSource(strings = {"1.2foo", "1.2_", ".5foo", "1.foo", "123nfoo"})
    void malformedNumberSuffixIsOneError(String source) {
        assertEquals(List.of(MiniJS.INVALID_NUMBER, MiniJS.SEMI), types(source + ";"));
        assertEquals(MiniJS.INVALID_NUMBER, types("`${" + source + "}`").get(2));
    }

    @ParameterizedTest
    @ValueSource(strings = {"1e+2foo", "1.2e-3foo", ".5e+2_", "1e+"})
    void malformedExponentIsOneError(String source) {
        assertEquals(List.of(MiniJS.INVALID_EXPONENT), types(source));
    }

    @Test void optionalChainDoesNotConsumeConditionalDecimal() {
        assertEquals(List.of(MiniJS.IDENTIFIER, MiniJS.OPTIONAL_CHAIN, MiniJS.IDENTIFIER,
                MiniJS.OPTIONAL_CHAIN, MiniJS.LBRACKET, MiniJS.INTEGER, MiniJS.RBRACKET),
                types("user?.items?.[0]"));
        assertEquals(List.of(MiniJS.IDENTIFIER, MiniJS.QUESTION, MiniJS.FLOAT,
                MiniJS.COLON, MiniJS.INTEGER), types("ok?.3:0"));
        assertEquals(MiniJS.OPTIONAL_CHAIN, types("`${user?.name}`").get(3));
    }

    @Test void additionalWhitespaceIsSkippedButIdentifiersRemainAscii() {
        assertEquals(List.of(MiniJS.LET, MiniJS.IDENTIFIER, MiniJS.ASSIGN, MiniJS.INTEGER),
                types("\uFEFFlet\u00A0x\u000B=\u20031"));
        assertEquals(List.of(MiniJS.INVALID_CHAR), types("\u0627"));
    }

    @Test void regexAndDivisionKeepTheirContexts() {
        assertEquals(List.of(MiniJS.REGEX, MiniJS.DOT, MiniJS.IDENTIFIER,
                MiniJS.LPAREN, MiniJS.IDENTIFIER, MiniJS.RPAREN), types("/[}/]+/g.test(x)"));
        assertEquals(List.of(MiniJS.IDENTIFIER, MiniJS.DIVIDE, MiniJS.INTEGER,
                MiniJS.DIVIDE, MiniJS.INTEGER), types("x / 2 / 3"));
        assertEquals(List.of(MiniJS.IDENTIFIER, MiniJS.DIVIDE_ASSIGN, MiniJS.INTEGER), types("x /= 2"));
        assertEquals(List.of(MiniJS.TEMPLATE_START, MiniJS.TEMPLATE_EXPR_START,
                MiniJS.REGEX, MiniJS.DOT, MiniJS.IDENTIFIER, MiniJS.LPAREN,
                MiniJS.IDENTIFIER, MiniJS.RPAREN, MiniJS.TEMPLATE_EXPR_END,
                MiniJS.TEMPLATE_END), types("`${ /}/.test(value) }`"));
        assertEquals(MiniJS.REGEX, types("if (x) /abc/.test(x)").get(4));
        assertEquals(MiniJS.DIVIDE, types("f(x) / 2").get(4));
        assertEquals(MiniJS.REGEX, types("`${{x:/}/}}`").get(5));
        assertEquals(List.of(MiniJS.REGEX), types("/a\\/b/gi"));
    }

    @Test void unfinishedRegexRecoversAtNextLine() throws Exception {
        assertEquals(List.of(MiniJS.UNCLOSED_REGEX, MiniJS.LET, MiniJS.IDENTIFIER,
                MiniJS.ASSIGN, MiniJS.INTEGER), types("/abc\nlet x=1"));
        assertTrue(report("/abc").contains("--- Lexical Errors: 1 ---"));
    }

    @Test void resetClearsRegexContext() {
        var lexer = new MiniJS(CharStreams.fromString("x"));
        lexer.getAllTokens();
        lexer.setInputStream(CharStreams.fromString("/abc/"));
        assertEquals(MiniJS.REGEX, lexer.nextToken().getType());
    }

    @ParameterizedTest
    @ValueSource(strings = {"obj.return / 2 / 3", "obj.if(x) / 2 / 3",
            "let f = function() {} / 2 / 3", "let f = () => {} / 2 / 3",
            "let x = {} / 2 / 3"})
    void expressionEndKeepsDivision(String source) {
        var tokens = types(source);
        assertFalse(tokens.contains(MiniJS.REGEX));
        assertEquals(2, tokens.stream().filter(t -> t == MiniJS.DIVIDE).count());
    }

    @Test void declarationAndBlockAllowFollowingRegexStatement() {
        assertEquals(MiniJS.REGEX, types("function f() {} /abc/").get(6));
        assertEquals(MiniJS.REGEX, types("if (x) {} /abc/").get(6));
    }

    @Test void numbers() {
        assertEquals(List.of(MiniJS.INTEGER, MiniJS.FLOAT, MiniJS.FLOAT, MiniJS.FLOAT,
                MiniJS.FLOAT, MiniJS.HEX_NUMBER, MiniJS.OCTAL_NUMBER, MiniJS.BINARY_NUMBER,
                MiniJS.BIGINT, MiniJS.INTEGER, MiniJS.INVALID_NUMBER, MiniJS.INVALID_EXPONENT),
                types("123 3.14 .5 5. 2.5E-3 0xFF 0o17 0b101 123n 1_000 345__2346 1e+"));
    }

    @Test void stringErrorRecoversAtNextLine() {
        var tokens = new MiniJS(CharStreams.fromString("\"abc\nvar t = 5;")).getAllTokens();
        assertEquals(MiniJS.UNCLOSED_STRING, tokens.get(0).getType());
        assertEquals(MiniJS.VAR, tokens.get(1).getType());
        assertEquals(2, tokens.get(1).getLine());
        assertEquals(0, tokens.get(1).getCharPositionInLine());
    }

    @Test void nestedTemplatesAndObjectBraces() {
        assertEquals(List.of(MiniJS.TEMPLATE_START, MiniJS.TEMPLATE_EXPR_START,
                MiniJS.TEMPLATE_START, MiniJS.TEMPLATE_EXPR_START, MiniJS.LBRACE,
                MiniJS.IDENTIFIER, MiniJS.COLON, MiniJS.INTEGER, MiniJS.RBRACE,
                MiniJS.DOT, MiniJS.IDENTIFIER, MiniJS.TEMPLATE_EXPR_END,
                MiniJS.TEMPLATE_END, MiniJS.TEMPLATE_EXPR_END, MiniJS.TEMPLATE_END),
                types("`${`${{x:1}.x}`}`"));
    }

    @Test void resetClearsModeStack() {
        var lexer = new MiniJS(CharStreams.fromString("`${{"));
        lexer.getAllTokens();
        lexer.setInputStream(CharStreams.fromString("}"));
        assertEquals(MiniJS.RBRACE, lexer.nextToken().getType());
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "let const var if else function return true false null class new this",
            "123 3.14 .5 5. 2.5E-3 0xFF 0o17 0b101 123n 1_000 345__2346 1e+ #",
            "a === b !== c >>>= 2 &&= true ??= false => ++x + y / 2; [x,y] ...x",
            "\"}\" '{' /* } ${ ` **/ // } ${ `\nname",
            "\"abc\\\ndef\" \"\\q\" 'It\\'s working'"
    })
    void codeTokensKeepTheirTypesAndTextInBothCodeModes(String source) {
        var expected = new MiniJS(CharStreams.fromString(source)).getAllTokens();
        for (String prefix : List.of("`${", "`${{")) {
            String suffix = prefix.endsWith("{{") ? "}}`" : "}`";
            var actual = new MiniJS(CharStreams.fromString(prefix + source + suffix)).getAllTokens();
            int start = prefix.endsWith("{{") ? 3 : 2;
            assertEquals(expected.size() + start * 2, actual.size());
            for (int i = 0; i < expected.size(); i++) {
                assertEquals(expected.get(i).getType(), actual.get(i + start).getType(), source);
                assertEquals(expected.get(i).getText(), actual.get(i + start).getText(), source);
                assertEquals(expected.get(i).getLine(), actual.get(i + start).getLine(), source);
            }
        }
    }

    @Test void multipleNestedBracesReturnToInterpolationThenText() {
        assertEquals(List.of(MiniJS.TEMPLATE_START, MiniJS.TEMPLATE_EXPR_START,
                MiniJS.LBRACE, MiniJS.LBRACE, MiniJS.INTEGER,
                MiniJS.RBRACE, MiniJS.RBRACE, MiniJS.PLUS, MiniJS.INTEGER,
                MiniJS.TEMPLATE_EXPR_END, MiniJS.TEMPLATE_TEXT, MiniJS.TEMPLATE_END,
                MiniJS.PLUS, MiniJS.INTEGER), types("`${{{1}}+2}done`+3"));
    }

    @Test void nestedTemplateInsideObjectRestoresBraceMode() {
        assertEquals(List.of(MiniJS.TEMPLATE_START, MiniJS.TEMPLATE_EXPR_START,
                MiniJS.LBRACE, MiniJS.IDENTIFIER, MiniJS.COLON,
                MiniJS.TEMPLATE_START, MiniJS.TEMPLATE_EXPR_START, MiniJS.IDENTIFIER,
                MiniJS.TEMPLATE_EXPR_END, MiniJS.TEMPLATE_END, MiniJS.RBRACE,
                MiniJS.DOT, MiniJS.IDENTIFIER, MiniJS.TEMPLATE_EXPR_END,
                MiniJS.TEMPLATE_END), types("`${{x:`${y}`}.x}`"));
    }

    @Test void ordinaryAndUnmatchedBracesDoNotPopAnEmptyStack() {
        assertEquals(List.of(MiniJS.RBRACE, MiniJS.LBRACE, MiniJS.LBRACE,
                MiniJS.RBRACE, MiniJS.RBRACE, MiniJS.RBRACE), types("}{{}}}"));
    }

    @Test void escapedInterpolationRemainsTemplateText() {
        assertEquals(List.of(MiniJS.TEMPLATE_START, MiniJS.TEMPLATE_TEXT,
                MiniJS.TEMPLATE_END), types("`\\${name}`"));
    }

    @Test void unfinishedObjectDoesNotCloseInterpolation() throws Exception {
        String output = report("`${{x:1}");
        assertTrue(output.contains("--- Lexical Errors: 2 ---"), output);
        assertTrue(output.contains("Unclosed template interpolation"), output);
        assertTrue(output.contains("Unclosed template literal"), output);
        assertFalse(output.contains("Type: TEMPLATE_EXPR_END"), output);
    }

    @ParameterizedTest
    @ValueSource(strings = {"`${/* unfinished", "`${{/* unfinished"})
    void unclosedCommentsInsideEitherCodeModeAreReported(String source) throws Exception {
        String output = report(source);
        assertTrue(output.contains("--- Lexical Errors: 3 ---"), output);
        assertTrue(output.contains("UNCLOSED_BLOCK_COMMENT"), output);
    }

    @Test void nativeErrorsAreCountedAndNotPrintedSeparately() throws Exception {
        String report = report("`abc\\");
        assertTrue(report.contains("--- Lexical Errors: 2 ---"), report);
        assertTrue(report.contains("Error at 1:4 - token recognition error"), report);
        assertTrue(report.contains("Error at 1:0 - Unclosed template literal"), report);
    }

    @Test void openInterpolationReportsBothDelimiters() throws Exception {
        String report = report("`hello ${x");
        assertTrue(report.contains("--- Lexical Errors: 2 ---"), report);
        assertTrue(report.contains("Error at 1:7 - Unclosed template interpolation"), report);
        assertTrue(report.contains("Error at 1:0 - Unclosed template literal"), report);
    }

    private String report(String text) throws Exception {
        Path path = tempDir.resolve("input.js");
        Files.writeString(path, text, StandardCharsets.UTF_8);
        var output = new ByteArrayOutputStream();
        var errors = new ByteArrayOutputStream();
        PrintStream originalOut = System.out, originalErr = System.err;
        try (var out = new PrintStream(output, true, StandardCharsets.UTF_8);
             var err = new PrintStream(errors, true, StandardCharsets.UTF_8)) {
            System.setOut(out);
            System.setErr(err);
            Main.main(new String[]{path.toString()});
        } finally {
            System.setOut(originalOut);
            System.setErr(originalErr);
        }
        assertEquals("", errors.toString(StandardCharsets.UTF_8));
        return output.toString(StandardCharsets.UTF_8);
    }
}
