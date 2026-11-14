// Keywords, identifiers, booleans and operators
let age = 20;
const name = "Ahmad";
var active = true && !false;
if (age >= 18) { age += 1; }

// Number formats
let numbers = [123, 3.14, .5, 5., 2.5E-3, 0xFF, 0o17, 0b1010, 123n, 1_000];

// Escapes, opposite quotes, and line continuation
var a = 'It\'s a "beautiful" day';
var b = "abc\
def";

/* A closed comment ending in several stars **/
let afterComment = 5;

// Multiline and nested template literals
let message = `Hello ${name}!
Age: ${age}`;
let nested = `a ${`b ${{name: "Ahmad"}.name}`} c`;
