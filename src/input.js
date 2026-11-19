#!/usr/bin/env node
// =====================================
// PART 1 - KEYWORDS AND OPERATORS
// =====================================

let age = 20;
const name = "Ahmad";
var total = age + 10;

if (age >= 18) {
    total += 5;
}

let a = 10 === 10;
let b = 5 !== 3;
let c = true && false;


// =====================================
// PART 2 - NUMBERS
// =====================================

let n1 = 123;
let n2 = 3.14;
let n3 = .5;
let n4 = 5.;
let n5 = 1e3;
let n6 = 2.5E-3;
let n7 = 0xFF;
let n8 = 0o17;
let n9 = 0b1010;
let n10 = 123n;
let n11 = 0xFFn;
let n12 = 1_000_000;


// =====================================
// PART 3 - STRINGS
// =====================================

let s1 = "Hello World";
let s2 = 'Hello World';
let s3 = 'It\'s working';
let s4 = "She said \"Hello\"";
let s5 = "back\\slash";
let s6 = "";
let s7 = 'say "hello"';

let s8 = "first line \
second line";

let s9 = "Hello\nWorld";


// =====================================
// PART 3 - COMMENTS
// =====================================

// This is a single-line comment

/* This is a block comment */

/*
 This comment
 spans multiple lines
*/

let result = 10; // Inline comment


// =====================================
// PART 4 - TEMPLATE LITERALS
// =====================================

let user = "Ahmad";

let t1 = `Hello World`;
let t2 = ``;
let t3 = `Hello ${user}!`;
let t4 = `Sum: ${10 + 20}`;

let t5 = `First line
Second line`;

let t6 = `Escaped \` backtick`;

let t7 = `Price: $5`;

let t8 = `${{name: "Ahmad"}.name}`;

let t9 = `a ${`b ${user}`} c`;

let division = 20 / 4;
let remainder = 10 % 3;
0/0

// =====================================
// PART 5 - SPECIAL CASES
// =====================================

class Counter {
    #count = 0;
    increment() { return ++this.#count; }
}

let optionalName = profile?.name ?? "Unknown";
let optionalItem = items?.[0];
let conditional = ready ? .3 : 0;

let hexDigits = 0xAB_CD;
let binaryDigits = 0b1010_0101;
let octalBigInt = 0o7_123n;
let exponentDigits = 1.2_5e+1_0;

let hexEscape = "\x41";
let unicodeEscape = "\u0041";
let unicodePoint = "\u{1F600}";
let literalEscape = "\\xzz";
let nullEscape = "\0A";

// The next lines contain a real NBSP and a real U+FEFF.
let withNbsp = 1;
let﻿withFeff = 2;

let pattern = /abc/g;
let characterClass = /* before the value */ /[a/]+/g;
let escapedSlash = /a\/b/i;
let chainedDivision = 12 / 2 / 3;
chainedDivision /= 2;
let regexThenDivision = /abc/ / 2;

let regexInTemplate = `${pattern = /}/}`;
let regexInNestedBraces = `${{p: (pattern = /}/)}.p}`;

// =====================================
// PART 6 - INTENTIONAL LEXICAL ERRORS
// =====================================

let badHexEscape = "\xZZ";       // INVALID_STRING
let shortHexEscape = "\x4";       // INVALID_STRING
let badCodePoint = "\u{110000}";  // INVALID_STRING
let badNullEscape = "\08";        // INVALID_STRING
let badNumber = 345__2346;        // INVALID_NUMBER
let attachedName = 5.5foo;       // INVALID_NUMBER
let badExponent = 1e+;          // INVALID_EXPONENT
@                                // INVALID_CHAR
let unclosedString = "unfinished
let recovery = 42;

// This case goes last and ends immediately after the backslash.
let unclosedTemplate = `Hello ${user}\