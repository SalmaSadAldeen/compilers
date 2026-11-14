lexer grammar MiniJS;

// The mode stack tracks template expressions and their nested braces.
// No Java actions or predicates are needed in this grammar.

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

// Ordinary code does not push/pop modes for braces.
LBRACE : '{';
RBRACE : '}';

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
    : '/*' (~[*] | '*'+ ~[*/])* '*'* EOF
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
    : '${' -> pushMode(INTERPOLATION_MODE)
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

// Code inside ${...}.
mode INTERPOLATION_MODE;

// Reuse the default patterns in the same priority order.
// type(...) preserves the public token types used by Main.
EXPR_LET : LET -> type(LET);
EXPR_CONST : CONST -> type(CONST);
EXPR_VAR : VAR -> type(VAR);
EXPR_IF : IF -> type(IF);
EXPR_ELSE : ELSE -> type(ELSE);
EXPR_FOR : FOR -> type(FOR);
EXPR_WHILE : WHILE -> type(WHILE);
EXPR_DO : DO -> type(DO);
EXPR_FUNCTION : FUNCTION -> type(FUNCTION);
EXPR_RETURN : RETURN -> type(RETURN);
EXPR_BREAK : BREAK -> type(BREAK);
EXPR_CONTINUE : CONTINUE -> type(CONTINUE);
EXPR_CLASS : CLASS -> type(CLASS);
EXPR_EXTENDS : EXTENDS -> type(EXTENDS);
EXPR_NEW : NEW -> type(NEW);
EXPR_THIS : THIS -> type(THIS);
EXPR_SUPER : SUPER -> type(SUPER);
EXPR_IMPORT : IMPORT -> type(IMPORT);
EXPR_EXPORT : EXPORT -> type(EXPORT);
EXPR_DEFAULT : DEFAULT -> type(DEFAULT);
EXPR_SWITCH : SWITCH -> type(SWITCH);
EXPR_CASE : CASE -> type(CASE);
EXPR_TRY : TRY -> type(TRY);
EXPR_CATCH : CATCH -> type(CATCH);
EXPR_FINALLY : FINALLY -> type(FINALLY);
EXPR_THROW : THROW -> type(THROW);
EXPR_TYPEOF : TYPEOF -> type(TYPEOF);
EXPR_INSTANCEOF : INSTANCEOF -> type(INSTANCEOF);
EXPR_IN : IN -> type(IN);
EXPR_VOID : VOID -> type(VOID);
EXPR_DELETE : DELETE -> type(DELETE);
EXPR_DEBUGGER : DEBUGGER -> type(DEBUGGER);
EXPR_WITH : WITH -> type(WITH);
EXPR_YIELD : YIELD -> type(YIELD);
EXPR_AWAIT : AWAIT -> type(AWAIT);
EXPR_ENUM : ENUM -> type(ENUM);
EXPR_TRUE : TRUE -> type(TRUE);
EXPR_FALSE : FALSE -> type(FALSE);
EXPR_NULL : NULL -> type(NULL);
EXPR_UNSIGNED_RIGHT_SHIFT_ASSIGN : UNSIGNED_RIGHT_SHIFT_ASSIGN -> type(UNSIGNED_RIGHT_SHIFT_ASSIGN);
EXPR_STRICT_EQUAL : STRICT_EQUAL -> type(STRICT_EQUAL);
EXPR_STRICT_NOT_EQUAL : STRICT_NOT_EQUAL -> type(STRICT_NOT_EQUAL);
EXPR_LEFT_SHIFT_ASSIGN : LEFT_SHIFT_ASSIGN -> type(LEFT_SHIFT_ASSIGN);
EXPR_RIGHT_SHIFT_ASSIGN : RIGHT_SHIFT_ASSIGN -> type(RIGHT_SHIFT_ASSIGN);
EXPR_POWER_ASSIGN : POWER_ASSIGN -> type(POWER_ASSIGN);
EXPR_AND_ASSIGN : AND_ASSIGN -> type(AND_ASSIGN);
EXPR_OR_ASSIGN : OR_ASSIGN -> type(OR_ASSIGN);
EXPR_NULLISH_ASSIGN : NULLISH_ASSIGN -> type(NULLISH_ASSIGN);
EXPR_EQUAL : EQUAL -> type(EQUAL);
EXPR_NOT_EQUAL : NOT_EQUAL -> type(NOT_EQUAL);
EXPR_LESS_EQUAL : LESS_EQUAL -> type(LESS_EQUAL);
EXPR_GREATER_EQUAL : GREATER_EQUAL -> type(GREATER_EQUAL);
EXPR_PLUS_ASSIGN : PLUS_ASSIGN -> type(PLUS_ASSIGN);
EXPR_MINUS_ASSIGN : MINUS_ASSIGN -> type(MINUS_ASSIGN);
EXPR_MULTIPLY_ASSIGN : MULTIPLY_ASSIGN -> type(MULTIPLY_ASSIGN);
EXPR_DIVIDE_ASSIGN : DIVIDE_ASSIGN -> type(DIVIDE_ASSIGN);
EXPR_MOD_ASSIGN : MOD_ASSIGN -> type(MOD_ASSIGN);
EXPR_BIT_AND_ASSIGN : BIT_AND_ASSIGN -> type(BIT_AND_ASSIGN);
EXPR_BIT_OR_ASSIGN : BIT_OR_ASSIGN -> type(BIT_OR_ASSIGN);
EXPR_BIT_XOR_ASSIGN : BIT_XOR_ASSIGN -> type(BIT_XOR_ASSIGN);
EXPR_INCREMENT : INCREMENT -> type(INCREMENT);
EXPR_DECREMENT : DECREMENT -> type(DECREMENT);
EXPR_UNSIGNED_RIGHT_SHIFT : UNSIGNED_RIGHT_SHIFT -> type(UNSIGNED_RIGHT_SHIFT);
EXPR_LEFT_SHIFT : LEFT_SHIFT -> type(LEFT_SHIFT);
EXPR_RIGHT_SHIFT : RIGHT_SHIFT -> type(RIGHT_SHIFT);
EXPR_POWER : POWER -> type(POWER);
EXPR_LOGICAL_AND : LOGICAL_AND -> type(LOGICAL_AND);
EXPR_LOGICAL_OR : LOGICAL_OR -> type(LOGICAL_OR);
EXPR_NULLISH : NULLISH -> type(NULLISH);
EXPR_ARROW : ARROW -> type(ARROW);
EXPR_PLUS : PLUS -> type(PLUS);
EXPR_MINUS : MINUS -> type(MINUS);
EXPR_MULTIPLY : MULTIPLY -> type(MULTIPLY);
EXPR_DIVIDE : DIVIDE -> type(DIVIDE);
EXPR_MOD : MOD -> type(MOD);
EXPR_ASSIGN : ASSIGN -> type(ASSIGN);
EXPR_LESS : LESS -> type(LESS);
EXPR_GREATER : GREATER -> type(GREATER);
EXPR_NOT : NOT -> type(NOT);
EXPR_BIT_AND : BIT_AND -> type(BIT_AND);
EXPR_BIT_OR : BIT_OR -> type(BIT_OR);
EXPR_BIT_XOR : BIT_XOR -> type(BIT_XOR);
EXPR_BIT_NOT : BIT_NOT -> type(BIT_NOT);
EXPR_QUESTION : QUESTION -> type(QUESTION);
EXPR_ELLIPSIS : ELLIPSIS -> type(ELLIPSIS);
EXPR_LPAREN : LPAREN -> type(LPAREN);
EXPR_RPAREN : RPAREN -> type(RPAREN);
EXPR_LBRACE : LBRACE -> type(LBRACE), pushMode(BRACE_MODE);
TEMPLATE_EXPR_END : '}' -> popMode;
EXPR_LBRACKET : LBRACKET -> type(LBRACKET);
EXPR_RBRACKET : RBRACKET -> type(RBRACKET);
EXPR_SEMI : SEMI -> type(SEMI);
EXPR_COMMA : COMMA -> type(COMMA);
EXPR_COLON : COLON -> type(COLON);
EXPR_DOT : DOT -> type(DOT);
EXPR_BIGINT : BIGINT -> type(BIGINT);
EXPR_HEX_NUMBER : HEX_NUMBER -> type(HEX_NUMBER);
EXPR_OCTAL_NUMBER : OCTAL_NUMBER -> type(OCTAL_NUMBER);
EXPR_BINARY_NUMBER : BINARY_NUMBER -> type(BINARY_NUMBER);
EXPR_FLOAT : FLOAT -> type(FLOAT);
EXPR_INTEGER : INTEGER -> type(INTEGER);
EXPR_INVALID_EXPONENT : INVALID_EXPONENT -> type(INVALID_EXPONENT);
EXPR_INVALID_NUMBER : INVALID_NUMBER -> type(INVALID_NUMBER);
EXPR_STRING : STRING -> type(STRING);
EXPR_UNCLOSED_STRING : UNCLOSED_STRING -> type(UNCLOSED_STRING);
EXPR_LINE_COMMENT : LINE_COMMENT -> type(LINE_COMMENT);
EXPR_BLOCK_COMMENT : BLOCK_COMMENT -> type(BLOCK_COMMENT);
EXPR_UNCLOSED_BLOCK_COMMENT : UNCLOSED_BLOCK_COMMENT -> type(UNCLOSED_BLOCK_COMMENT);
EXPR_IDENTIFIER : IDENTIFIER -> type(IDENTIFIER);
EXPR_WS : WS -> skip;
EXPR_TEMPLATE_START : TEMPLATE_START -> type(TEMPLATE_START), pushMode(TEMPLATE_MODE);
EXPR_INVALID_CHAR : INVALID_CHAR -> type(INVALID_CHAR);

// Code inside nested {...} within an interpolation.
mode BRACE_MODE;

// Reuse the default patterns in the same priority order.
// type(...) preserves the public token types used by Main.
BRACE_LET : LET -> type(LET);
BRACE_CONST : CONST -> type(CONST);
BRACE_VAR : VAR -> type(VAR);
BRACE_IF : IF -> type(IF);
BRACE_ELSE : ELSE -> type(ELSE);
BRACE_FOR : FOR -> type(FOR);
BRACE_WHILE : WHILE -> type(WHILE);
BRACE_DO : DO -> type(DO);
BRACE_FUNCTION : FUNCTION -> type(FUNCTION);
BRACE_RETURN : RETURN -> type(RETURN);
BRACE_BREAK : BREAK -> type(BREAK);
BRACE_CONTINUE : CONTINUE -> type(CONTINUE);
BRACE_CLASS : CLASS -> type(CLASS);
BRACE_EXTENDS : EXTENDS -> type(EXTENDS);
BRACE_NEW : NEW -> type(NEW);
BRACE_THIS : THIS -> type(THIS);
BRACE_SUPER : SUPER -> type(SUPER);
BRACE_IMPORT : IMPORT -> type(IMPORT);
BRACE_EXPORT : EXPORT -> type(EXPORT);
BRACE_DEFAULT : DEFAULT -> type(DEFAULT);
BRACE_SWITCH : SWITCH -> type(SWITCH);
BRACE_CASE : CASE -> type(CASE);
BRACE_TRY : TRY -> type(TRY);
BRACE_CATCH : CATCH -> type(CATCH);
BRACE_FINALLY : FINALLY -> type(FINALLY);
BRACE_THROW : THROW -> type(THROW);
BRACE_TYPEOF : TYPEOF -> type(TYPEOF);
BRACE_INSTANCEOF : INSTANCEOF -> type(INSTANCEOF);
BRACE_IN : IN -> type(IN);
BRACE_VOID : VOID -> type(VOID);
BRACE_DELETE : DELETE -> type(DELETE);
BRACE_DEBUGGER : DEBUGGER -> type(DEBUGGER);
BRACE_WITH : WITH -> type(WITH);
BRACE_YIELD : YIELD -> type(YIELD);
BRACE_AWAIT : AWAIT -> type(AWAIT);
BRACE_ENUM : ENUM -> type(ENUM);
BRACE_TRUE : TRUE -> type(TRUE);
BRACE_FALSE : FALSE -> type(FALSE);
BRACE_NULL : NULL -> type(NULL);
BRACE_UNSIGNED_RIGHT_SHIFT_ASSIGN : UNSIGNED_RIGHT_SHIFT_ASSIGN -> type(UNSIGNED_RIGHT_SHIFT_ASSIGN);
BRACE_STRICT_EQUAL : STRICT_EQUAL -> type(STRICT_EQUAL);
BRACE_STRICT_NOT_EQUAL : STRICT_NOT_EQUAL -> type(STRICT_NOT_EQUAL);
BRACE_LEFT_SHIFT_ASSIGN : LEFT_SHIFT_ASSIGN -> type(LEFT_SHIFT_ASSIGN);
BRACE_RIGHT_SHIFT_ASSIGN : RIGHT_SHIFT_ASSIGN -> type(RIGHT_SHIFT_ASSIGN);
BRACE_POWER_ASSIGN : POWER_ASSIGN -> type(POWER_ASSIGN);
BRACE_AND_ASSIGN : AND_ASSIGN -> type(AND_ASSIGN);
BRACE_OR_ASSIGN : OR_ASSIGN -> type(OR_ASSIGN);
BRACE_NULLISH_ASSIGN : NULLISH_ASSIGN -> type(NULLISH_ASSIGN);
BRACE_EQUAL : EQUAL -> type(EQUAL);
BRACE_NOT_EQUAL : NOT_EQUAL -> type(NOT_EQUAL);
BRACE_LESS_EQUAL : LESS_EQUAL -> type(LESS_EQUAL);
BRACE_GREATER_EQUAL : GREATER_EQUAL -> type(GREATER_EQUAL);
BRACE_PLUS_ASSIGN : PLUS_ASSIGN -> type(PLUS_ASSIGN);
BRACE_MINUS_ASSIGN : MINUS_ASSIGN -> type(MINUS_ASSIGN);
BRACE_MULTIPLY_ASSIGN : MULTIPLY_ASSIGN -> type(MULTIPLY_ASSIGN);
BRACE_DIVIDE_ASSIGN : DIVIDE_ASSIGN -> type(DIVIDE_ASSIGN);
BRACE_MOD_ASSIGN : MOD_ASSIGN -> type(MOD_ASSIGN);
BRACE_BIT_AND_ASSIGN : BIT_AND_ASSIGN -> type(BIT_AND_ASSIGN);
BRACE_BIT_OR_ASSIGN : BIT_OR_ASSIGN -> type(BIT_OR_ASSIGN);
BRACE_BIT_XOR_ASSIGN : BIT_XOR_ASSIGN -> type(BIT_XOR_ASSIGN);
BRACE_INCREMENT : INCREMENT -> type(INCREMENT);
BRACE_DECREMENT : DECREMENT -> type(DECREMENT);
BRACE_UNSIGNED_RIGHT_SHIFT : UNSIGNED_RIGHT_SHIFT -> type(UNSIGNED_RIGHT_SHIFT);
BRACE_LEFT_SHIFT : LEFT_SHIFT -> type(LEFT_SHIFT);
BRACE_RIGHT_SHIFT : RIGHT_SHIFT -> type(RIGHT_SHIFT);
BRACE_POWER : POWER -> type(POWER);
BRACE_LOGICAL_AND : LOGICAL_AND -> type(LOGICAL_AND);
BRACE_LOGICAL_OR : LOGICAL_OR -> type(LOGICAL_OR);
BRACE_NULLISH : NULLISH -> type(NULLISH);
BRACE_ARROW : ARROW -> type(ARROW);
BRACE_PLUS : PLUS -> type(PLUS);
BRACE_MINUS : MINUS -> type(MINUS);
BRACE_MULTIPLY : MULTIPLY -> type(MULTIPLY);
BRACE_DIVIDE : DIVIDE -> type(DIVIDE);
BRACE_MOD : MOD -> type(MOD);
BRACE_ASSIGN : ASSIGN -> type(ASSIGN);
BRACE_LESS : LESS -> type(LESS);
BRACE_GREATER : GREATER -> type(GREATER);
BRACE_NOT : NOT -> type(NOT);
BRACE_BIT_AND : BIT_AND -> type(BIT_AND);
BRACE_BIT_OR : BIT_OR -> type(BIT_OR);
BRACE_BIT_XOR : BIT_XOR -> type(BIT_XOR);
BRACE_BIT_NOT : BIT_NOT -> type(BIT_NOT);
BRACE_QUESTION : QUESTION -> type(QUESTION);
BRACE_ELLIPSIS : ELLIPSIS -> type(ELLIPSIS);
BRACE_LPAREN : LPAREN -> type(LPAREN);
BRACE_RPAREN : RPAREN -> type(RPAREN);
BRACE_LBRACE : LBRACE -> type(LBRACE), pushMode(BRACE_MODE);
BRACE_RBRACE : RBRACE -> type(RBRACE), popMode;
BRACE_LBRACKET : LBRACKET -> type(LBRACKET);
BRACE_RBRACKET : RBRACKET -> type(RBRACKET);
BRACE_SEMI : SEMI -> type(SEMI);
BRACE_COMMA : COMMA -> type(COMMA);
BRACE_COLON : COLON -> type(COLON);
BRACE_DOT : DOT -> type(DOT);
BRACE_BIGINT : BIGINT -> type(BIGINT);
BRACE_HEX_NUMBER : HEX_NUMBER -> type(HEX_NUMBER);
BRACE_OCTAL_NUMBER : OCTAL_NUMBER -> type(OCTAL_NUMBER);
BRACE_BINARY_NUMBER : BINARY_NUMBER -> type(BINARY_NUMBER);
BRACE_FLOAT : FLOAT -> type(FLOAT);
BRACE_INTEGER : INTEGER -> type(INTEGER);
BRACE_INVALID_EXPONENT : INVALID_EXPONENT -> type(INVALID_EXPONENT);
BRACE_INVALID_NUMBER : INVALID_NUMBER -> type(INVALID_NUMBER);
BRACE_STRING : STRING -> type(STRING);
BRACE_UNCLOSED_STRING : UNCLOSED_STRING -> type(UNCLOSED_STRING);
BRACE_LINE_COMMENT : LINE_COMMENT -> type(LINE_COMMENT);
BRACE_BLOCK_COMMENT : BLOCK_COMMENT -> type(BLOCK_COMMENT);
BRACE_UNCLOSED_BLOCK_COMMENT : UNCLOSED_BLOCK_COMMENT -> type(UNCLOSED_BLOCK_COMMENT);
BRACE_IDENTIFIER : IDENTIFIER -> type(IDENTIFIER);
BRACE_WS : WS -> skip;
BRACE_TEMPLATE_START : TEMPLATE_START -> type(TEMPLATE_START), pushMode(TEMPLATE_MODE);
BRACE_INVALID_CHAR : INVALID_CHAR -> type(INVALID_CHAR);