lexer grammar MiniJS;

@members {
    private final java.util.ArrayDeque<Integer> braceDepth =
        new java.util.ArrayDeque<>();

    private void startInterpolation() {
        braceDepth.push(0);
    }

    private boolean isInterpolationEnd() {
        return !braceDepth.isEmpty()
            && braceDepth.peek() == 0;
    }

    private void openBrace() {
        if (!braceDepth.isEmpty()) {
            braceDepth.push(braceDepth.pop() + 1);
        }
    }

    private void closeBrace() {
        if (!braceDepth.isEmpty()) {
            braceDepth.push(braceDepth.pop() - 1);
        }
    }

    private void endInterpolation() {
        braceDepth.pop();
    }
}

// ================= PART 1: KEYWORDS =================

LET        : 'let';
CONST      : 'const';
VAR        : 'var';
IF         : 'if';
ELSE       : 'else';
FOR        : 'for';
WHILE      : 'while';
DO         : 'do';
FUNCTION   : 'function';
RETURN     : 'return';
BREAK      : 'break';
CONTINUE   : 'continue';
CLASS      : 'class';
EXTENDS    : 'extends';
NEW        : 'new';
THIS       : 'this';
SUPER      : 'super';
IMPORT     : 'import';
EXPORT     : 'export';
DEFAULT    : 'default';
SWITCH     : 'switch';
CASE       : 'case';
TRY        : 'try';
CATCH      : 'catch';
FINALLY    : 'finally';
THROW      : 'throw';
TYPEOF     : 'typeof';
INSTANCEOF : 'instanceof';
IN         : 'in';
VOID       : 'void';
DELETE     : 'delete';
DEBUGGER   : 'debugger';
WITH       : 'with';
YIELD      : 'yield';
AWAIT      : 'await';
ENUM       : 'enum';

TRUE       : 'true';
FALSE      : 'false';
NULL       : 'null';

// ================= PART 1: OPERATORS =================

UNSIGNED_RIGHT_SHIFT_ASSIGN : '>>>=';

STRICT_EQUAL       : '===';
STRICT_NOT_EQUAL   : '!==';

LEFT_SHIFT_ASSIGN  : '<<=';
RIGHT_SHIFT_ASSIGN : '>>=';

POWER_ASSIGN       : '**=';
AND_ASSIGN         : '&&=';
OR_ASSIGN          : '||=';
NULLISH_ASSIGN     : '??=';

EQUAL              : '==';
NOT_EQUAL          : '!=';
LESS_EQUAL         : '<=';
GREATER_EQUAL      : '>=';

PLUS_ASSIGN        : '+=';
MINUS_ASSIGN       : '-=';
MULTIPLY_ASSIGN    : '*=';
DIVIDE_ASSIGN      : '/=';
MOD_ASSIGN         : '%=';

BIT_AND_ASSIGN     : '&=';
BIT_OR_ASSIGN      : '|=';
BIT_XOR_ASSIGN     : '^=';

INCREMENT          : '++';
DECREMENT          : '--';

UNSIGNED_RIGHT_SHIFT : '>>>';
LEFT_SHIFT           : '<<';
RIGHT_SHIFT          : '>>';

POWER                : '**';
LOGICAL_AND          : '&&';
LOGICAL_OR           : '||';
NULLISH              : '??';
ARROW                : '=>';

PLUS          : '+';
MINUS         : '-';
MULTIPLY      : '*';
DIVIDE        : '/';
MOD           : '%';

ASSIGN        : '=';
LESS          : '<';
GREATER       : '>';

NOT           : '!';

BIT_AND       : '&';
BIT_OR        : '|';
BIT_XOR       : '^';
BIT_NOT       : '~';

QUESTION      : '?';

// ================= PART 1: PUNCTUATION =================

ELLIPSIS : '...';

LPAREN   : '(';
RPAREN   : ')';

// When brace depth is zero,
// } ends the ${...} interpolation.

TEMPLATE_EXPR_END
    : {isInterpolationEnd()}? '}'
      {endInterpolation();}
      -> popMode
    ;

LBRACE
    : '{' {openBrace();}
    ;

RBRACE
    : '}' {closeBrace();}
    ;

LBRACKET : '[';
RBRACKET : ']';

SEMI     : ';';
COMMA    : ',';
COLON    : ':';
DOT      : '.';

// ================= PART 2: NUMBERS =================

// BigInt
BIGINT
    : (DECIMAL_INTEGER
      | HEX_INTEGER
      | OCTAL_INTEGER
      | BINARY_INTEGER) 'n'
    ;

// Hexadecimal
HEX_NUMBER
    : HEX_INTEGER
    ;

// Octal
OCTAL_NUMBER
    : OCTAL_INTEGER
    ;

// Binary
BINARY_NUMBER
    : BINARY_INTEGER
    ;

// Floating-point numbers
FLOAT
    : DECIMAL_INTEGER '.' DECIMAL_DIGITS? EXPONENT?
    | '.' DECIMAL_DIGITS EXPONENT?
    | DECIMAL_INTEGER EXPONENT
    ;

// Decimal integers
INTEGER
    : DECIMAL_INTEGER
    ;

// ================= PART 2: INVALID NUMBERS =================

INVALID_EXPONENT
    : (DECIMAL_INTEGER ('.' DECIMAL_DIGITS?)?
      | '.' DECIMAL_DIGITS)
      [eE] [+-]? [a-zA-Z0-9_$]*
    ;

INVALID_NUMBER
    : DIGIT [a-zA-Z0-9_$]*
      ('.' [a-zA-Z0-9_$]+)?
    | '.' DECIMAL_DIGITS
      [a-zA-Z_$] [a-zA-Z0-9_$]*
    ;

// ================= PART 2: NUMBER FRAGMENTS =================

fragment DIGIT
    : [0-9]
    ;

fragment DECIMAL_DIGITS
    : DIGIT ('_'? DIGIT)*
    ;

fragment DECIMAL_INTEGER
    : '0'
    | [1-9] ('_'? DIGIT)*
    ;

fragment HEX_DIGIT
    : [0-9a-fA-F]
    ;

fragment HEX_INTEGER
    : '0' [xX] HEX_DIGIT ('_'? HEX_DIGIT)*
    ;

fragment OCTAL_INTEGER
    : '0' [oO] [0-7] ('_'? [0-7])*
    ;

fragment BINARY_INTEGER
    : '0' [bB] [01] ('_'? [01])*
    ;

fragment EXPONENT
    : [eE] [+-]? DECIMAL_DIGITS
    ;

// ================= PART 3: STRINGS =================

STRING
    : '"' (STRING_ESCAPE | ~["\\\r\n\u2028\u2029])* '"'
    | '\'' (STRING_ESCAPE | ~['\\\r\n\u2028\u2029])* '\''
    ;

// Unterminated strings
UNCLOSED_STRING
    : '"' (STRING_ESCAPE | ~["\\\r\n\u2028\u2029])*
          '\\'? (LINE_TERMINATOR | EOF)

    | '\'' (STRING_ESCAPE | ~['\\\r\n\u2028\u2029])*
          '\\'? (LINE_TERMINATOR | EOF)
    ;

// Escaped characters
fragment STRING_ESCAPE
    : '\\' (LINE_TERMINATOR | ~[\r\n\u2028\u2029])
    ;

// Line terminators
fragment LINE_TERMINATOR
    : '\r\n'
    | [\r\n\u2028\u2029]
    ;

// ================= PART 3: COMMENTS =================

// Single-line comments
LINE_COMMENT
    : '//' ~[\r\n\u2028\u2029]*
    ;

// Multi-line comments
BLOCK_COMMENT
    : '/*' .*? '*/'
    ;

// Unterminated block comments
UNCLOSED_BLOCK_COMMENT
    : '/*' (~[*] | '*' ~[/])* '*'? EOF
    ;


// ================= IDENTIFIERS =================

IDENTIFIER
    : [a-zA-Z_$] [a-zA-Z0-9_$]*
    ;

// ================= WHITESPACE =================

WS
    : [ \t\r\n\u2028\u2029]+ -> skip
    ;

// ================= PART 4: TEMPLATE START =================

TEMPLATE_START
    : '`' -> pushMode(TEMPLATE_MODE)
    ;

// ================= INVALID CHARACTERS =================

// Must be last rule in DEFAULT_MODE.
INVALID_CHAR
    : .
    ;

// ================= PART 4: TEMPLATE LITERALS =================

mode TEMPLATE_MODE;

// Closing backtick
TEMPLATE_END
    : '`' -> popMode
    ;

// Interpolation start
TEMPLATE_EXPR_START
    : '${' {startInterpolation();}
      -> pushMode(DEFAULT_MODE)
    ;

// Template content
TEMPLATE_TEXT
    : ( '\\' .
      | ~[`\\$]
      )+
    ;

// Standalone dollar sign
TEMPLATE_DOLLAR
    : '$' -> type(TEMPLATE_TEXT)
    ;
