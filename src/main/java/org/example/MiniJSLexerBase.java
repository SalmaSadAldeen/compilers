package org.example;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Token;
import java.util.ArrayDeque;
import java.util.Deque;

/** Lexical expression context for MiniJS; full syntactic validation belongs to a parser. */
public abstract class MiniJSLexerBase extends Lexer {
    private int previous = Token.INVALID_TYPE;
    private boolean expressionExpected = true;
    // Parentheses: call/group=0, control=1, function declaration=2, function expression=3.
    private final Deque<Integer> controlParens = new ArrayDeque<>();
    private final Deque<Boolean> objectBraces = new ArrayDeque<>();
    private Integer pendingFunction;
    private Boolean functionBodyExpression;

    protected MiniJSLexerBase(CharStream input) { super(input); }

    protected boolean isRegexPossible() { return expressionExpected; }

    protected boolean unicodeEscapeInRange() {
        String text = getText();
        int start = text.lastIndexOf('{');
        if (start < 0) return false;
        try {
            return new java.math.BigInteger(text.substring(start + 1, text.length() - 1), 16)
                    .compareTo(java.math.BigInteger.valueOf(0x10FFFF)) <= 0;
        } catch (NumberFormatException e) { return false; }
    }

    @Override public void reset() {
        super.reset();
        previous = Token.INVALID_TYPE;
        expressionExpected = true;
        pendingFunction = null;
        functionBodyExpression = null;
        // Lexer construction may invoke reset before subclass fields are initialized.
        if (controlParens != null) controlParens.clear();
        if (objectBraces != null) objectBraces.clear();
    }

    @Override public Token nextToken() {
        Token token = super.nextToken();
        int type = token.getType();
        if (type == Token.EOF || type == MiniJS.LINE_COMMENT || type == MiniJS.BLOCK_COMMENT
                || type == MiniJS.UNCLOSED_BLOCK_COMMENT || type == MiniJS.TEMPLATE_TEXT) return token;
        boolean wasExpected = expressionExpected;
        // Reserved words are permitted as property names: obj.return / 2 is division.
        if ((previous == MiniJS.DOT || previous == MiniJS.OPTIONAL_CHAIN)
                && token.getText().matches("[a-zA-Z_$][a-zA-Z0-9_$]*")) {
            previous = MiniJS.IDENTIFIER;
            expressionExpected = false;
            return token;
        }
        switch (type) {
            case MiniJS.FUNCTION -> {
                boolean expression = previous != Token.INVALID_TYPE && previous != MiniJS.SEMI
                        && previous != MiniJS.LBRACE && previous != MiniJS.RBRACE
                        && previous != MiniJS.EXPORT && previous != MiniJS.DEFAULT;
                pendingFunction = expression ? 3 : 2;
                expressionExpected = true;
            }
            case MiniJS.LPAREN -> {
                boolean control = previous == MiniJS.IF || previous == MiniJS.WHILE
                        || previous == MiniJS.FOR || previous == MiniJS.WITH
                        || previous == MiniJS.SWITCH || previous == MiniJS.CATCH;
                controlParens.push(pendingFunction != null ? pendingFunction : control ? 1 : 0);
                pendingFunction = null;
                expressionExpected = true;
            }
            case MiniJS.RPAREN -> {
                int context = controlParens.isEmpty() ? 0 : controlParens.pop();
                expressionExpected = context == 1;
                if (context >= 2) functionBodyExpression = context == 3;
            }
            case MiniJS.LBRACE -> {
                boolean object = wasExpected && (previous == MiniJS.ASSIGN || previous == MiniJS.LPAREN
                        || previous == MiniJS.LBRACKET || previous == MiniJS.COMMA
                        || previous == MiniJS.COLON || previous == MiniJS.RETURN
                        || previous == MiniJS.TEMPLATE_EXPR_START);
                if (previous == MiniJS.ARROW) object = true;
                if (previous == MiniJS.RPAREN && functionBodyExpression != null) {
                    object = functionBodyExpression;
                    functionBodyExpression = null;
                }
                objectBraces.push(object);
                expressionExpected = true;
            }
            case MiniJS.RBRACE -> expressionExpected = objectBraces.isEmpty() || !objectBraces.pop();
            case MiniJS.IDENTIFIER, MiniJS.INTEGER, MiniJS.FLOAT, MiniJS.BIGINT,
                    MiniJS.HEX_NUMBER, MiniJS.OCTAL_NUMBER, MiniJS.BINARY_NUMBER,
                    MiniJS.STRING, MiniJS.INVALID_STRING, MiniJS.REGEX, MiniJS.TRUE,
                    MiniJS.FALSE, MiniJS.NULL, MiniJS.THIS, MiniJS.SUPER,
                    MiniJS.RBRACKET, MiniJS.TEMPLATE_END, MiniJS.TEMPLATE_EXPR_END,
                    MiniJS.DOT, MiniJS.OPTIONAL_CHAIN -> expressionExpected = false;
            case MiniJS.INCREMENT, MiniJS.DECREMENT -> expressionExpected = wasExpected;
            default -> expressionExpected = true;
        }
        previous = type;
        return token;
    }
}
