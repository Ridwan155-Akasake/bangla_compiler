%{
#include "ProjectParser.h"
#include "ProjectParser.tab.h"
#include <stdio.h>
#include <stdlib.h>  // For strdup and free
%}



%option noyywrap

%%
[ \t\n\r]+                    { /* Skip whitespace */ }

"যদি"                          { return IF; }        // Bangla "if"
"নয়ত_যদি"                     { return ELSE_IF; }   // Bangla "else if"
"নয়ত"                         { return ELSE; }      // Bangla "else"
"দেখাও"                        { return PRINT; }     // Bangla "print"
"নাও"                          { return SCAN; }      // Bangla "scanf"

"সংখ্যা"                        { return INT; }       // Bangla "int"
"শুধু_দশমিক"                   { return FLOAT; }     // Bangla "float"
"দশমিক"                       { return DOUBLE; }    // Bangla "double"
"বাক্য"                         { return STRING; }    // Bangla "string"

"যোগ"                          { return ADD; }       // Bangla "add"
"বিয়োগ"                        { return SUB; }       // Bangla "subtract"
"গুণ"                           { return MUL; }       // Bangla "multiply"
"ভাগ"                           { return DIV; }       // Bangla "divide"

"=="                           { return EQ; }        // Equality operator
"!="                           { return NEQ; }       // Not equal operator
"<"                            { return LT; }        // Less than operator
">"                            { return GT; }        // Greater than operator
"<="                           { return LE; }        // Less than or equal operator
">="                           { return GE; }        // Greater than or equal operator
"="                            { return '='; }       // Assignment operator

[0-9]+                         { yylval.num = atoi(yytext); return NUMBER; }        // Integer number
[0-9]+\.[0-9]+                 { yylval.fnum = atof(yytext); return FLOAT_NUMBER; printf("Lexer: FLOAT_NUMBER = %f\n", yylval.fnum); } // Float number
[A-Za-z_][A-Za-z0-9_]*         { yylval.str = strdup(yytext); return ID; }          // Identifier (variable names)


"("                            { return '('; }       // Left parenthesis
")"                            { return ')'; }       // Right parenthesis
"{"                            { return '{'; }       // Left brace
"}"                            { return '}'; }       // Right brace
":"                            { return ':'; }       // Semicolon

.                               { fprintf(stderr, "Invalid character: %s\n", yytext); return -1; }  // Any other character (error handling)

%%

