package org.example;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Token;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

public class Main {
    public static void main(String[] args) throws IOException {
        String filePath = args.length > 0
                ? args[0]
                : "src/input.js";

        CharStream input = CharStreams.fromPath(
                Paths.get(filePath), StandardCharsets.UTF_8);
        MiniJS lexer = new MiniJS(input);

        List<Token> validTokens = new ArrayList<>();
        List<String> errors = new ArrayList<>();
        Deque<Token> openTemplates = new ArrayDeque<>();
        Deque<Token> openExpressions = new ArrayDeque<>();

//        lexer.removeErrorListeners();
//        lexer.addErrorListener(new BaseErrorListener() {
//            @Override
//            public void syntaxError(
//                    Recognizer<?, ?> recognizer,
//                    Object offendingSymbol,
//                    int line,
//                    int column,
//                    String message,
//                    RecognitionException exception) {
//                errors.add("Error at " + line + ":" + column
//                        + " - " + message);
//            }
//        });

        while (true) {
            Token token = lexer.nextToken();
            int type = token.getType();
            if (type == Token.EOF) break;

            // Keep track of delimiters for reporting unfinished templates.
            if (type == MiniJS.TEMPLATE_START) {
                openTemplates.push(token);
            } else if (type == MiniJS.TEMPLATE_END) {
                if (!openTemplates.isEmpty()) openTemplates.pop();
            } else if (type == MiniJS.TEMPLATE_EXPR_START) {
                openExpressions.push(token);
            } else if (type == MiniJS.TEMPLATE_EXPR_END) {
                if (!openExpressions.isEmpty()) openExpressions.pop();
            }

            if (isErrorToken(type)) {
                errors.add("Error at " + token.getLine() + ":"
                        + token.getCharPositionInLine() + " - "
                        + lexer.getVocabulary().getSymbolicName(type)
                        + ": " + printable(token.getText()));
            } else {
                validTokens.add(token);
            }
        }

        for (Token token : openExpressions) {
            errors.add("Error at " + token.getLine() + ":"
                    + token.getCharPositionInLine()
                    + " - Unclosed template interpolation");
        }
        for (Token token : openTemplates) {
            errors.add("Error at " + token.getLine() + ":"
                    + token.getCharPositionInLine()
                    + " - Unclosed template literal");
        }

        System.out.println("--- Tokens Found ---");
        for (Token token : validTokens) {
            String typeName = lexer.getVocabulary()
                    .getSymbolicName(token.getType());
            if (typeName == null) {
                typeName = lexer.getVocabulary()
                        .getDisplayName(token.getType());
            }
            System.out.printf(
                    "Text: [%s] -> Type: %s (%d:%d)%n",
                    printable(token.getText()),
                    typeName,
                    token.getLine(),
                    token.getCharPositionInLine());
        }

        System.out.println("\n--- Lexical Errors: " + errors.size() + " ---");
        for (String error : errors) System.out.println(error);
    }

    private static boolean isErrorToken(int type) {
        return type == MiniJS.INVALID_CHAR
                || type == MiniJS.INVALID_NUMBER
                || type == MiniJS.INVALID_EXPONENT
                || type == MiniJS.UNCLOSED_STRING
                || type == MiniJS.UNCLOSED_BLOCK_COMMENT;
    }

    private static String printable(String text) {
        if (text == null) return "";
        return text.replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("\t", "\\t")
                .replace(String.valueOf((char) 0x2028), "\\u2028")
                .replace(String.valueOf((char) 0x2029), "\\u2029");
    }
}
