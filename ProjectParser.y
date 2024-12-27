%{
#include "ProjectParser.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ProjectParser.tab.h"

extern FILE *yyin;
extern int yylex(void);
extern int yyerror(char *s);

#define MAX_SYMBOLS 100

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

%}

%union {
    int num;        // For integers
    float fnum;     // For floats
    double dnum;    // For doubles
    char* str;      // For strings (IDs)
    DataType type;  // For data types (int, float, etc.)
    int cmp;         // For comparison results (1 for true, 0 for false)
}

%left ADD SUB
%left MUL DIV
%left EQ NEQ LT GT LE GE
%left UMINUS

%token IF ELSE_IF ELSE PRINT SCAN INT FLOAT DOUBLE STRING EQ NEQ LT GT LE GE
%token <str> ID
%token <num> NUMBER
%token <fnum> FLOAT_NUMBER
%token ADD SUB MUL DIV

%type <num> expression
%type <cmp> comparison
%type <type> datatype

%%

program:
    statements
    ;

statements:
    statements statement
    | statement
    ;

statement:
    datatype ID ';' {
        addSymbol($2, $1, NULL);  // Declare a variable
        printf("Declared %s of type %d\n", $2, $1);
    }
    | PRINT ID ';' {
        printf("Printing variable %s\n", $2);
        int idx = findSymbolIndex($2);
        if (idx != -1) {
            if (symbolTable[idx].type == INT_TYPE) {
                printf("%d\n", symbolTable[idx].intValue);
            } else if (symbolTable[idx].type == FLOAT_TYPE) {
                printf("%f\n", symbolTable[idx].floatValue);
            } else if (symbolTable[idx].type == DOUBLE_TYPE) {
                printf("%lf\n", symbolTable[idx].doubleValue);
            } else if (symbolTable[idx].type == STRING_TYPE) {
                printf("%s\n", symbolTable[idx].stringValue);
            }
        }
    }
    
    | SCAN ID ';' {
        printf("Enter value for %s: ", $2);
        int value;
        scanf("%d", &value);
        printf("Assigning value: %d\n", value);
        int idx = findSymbolIndex($2);
        if (idx != -1) {
            if (symbolTable[idx].type == INT_TYPE) {
                printf("Assigning int value: %d\n", value);
                symbolTable[idx].intValue = value;
            } else if (symbolTable[idx].type == FLOAT_TYPE) {
                printf("Assigning float value: %f\n", value);
                symbolTable[idx].floatValue = value;
            } else if (symbolTable[idx].type == DOUBLE_TYPE) {
                printf("Assigning double value: %f\n", value);
                symbolTable[idx].doubleValue = value;
            }
        }
    }
    | ID '=' expression ';' {
        printf("Assigning value to %s\n", $1);
        int idx = findSymbolIndex($1);
        if (idx != -1) {
            if (symbolTable[idx].type == INT_TYPE) {
                printf("Assigning int value: %d\n", $3);
                symbolTable[idx].intValue = $3;
            } else if (symbolTable[idx].type == FLOAT_TYPE) {
                printf("Assigning float value: %f\n", $3);
                symbolTable[idx].floatValue = $3;
            } else if (symbolTable[idx].type == DOUBLE_TYPE) {
                printf("Assigning double value: %f\n", $3);
                symbolTable[idx].doubleValue = $3;
            }
        }
    }
    | IF comparison '{' statements '}' ELSE '{' statement '}' {
        printf("Conditional statement Found");
        if ($2) {
            printf("IF block execued\n");
        } else {
            printf("IF condition false, executing ELSE block\n");
        }
    }
    | IF comparison '{' statements '}' ELSE_IF comparison '{' statements '}' ELSE '{' statements '}' {
        if ($2) {
            printf("IF block executed\n");
        } else if ($7) {
            printf("ELSE_IF block executed\n");
        } else {
            printf("Both IF and ELSE_IF blocks skipped\n");
        }
    }
    ;

datatype:
    INT {
        $$ = INT_TYPE;
    }
    | FLOAT {
        $$ = FLOAT_TYPE;
    }
    | DOUBLE {
        $$ = DOUBLE_TYPE;
    }
    | STRING {
        $$ = STRING_TYPE;
    }
    ;

expression:
    expression ADD expression {
        $$ = $1 + $3;
    }
    | expression SUB expression {
        $$ = $1 - $3;
    }
    | expression MUL expression {
        $$ = $1 * $3;
    }
    | expression DIV expression {
        if ($3 == 0) {
            yyerror("Division by zero!");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }

    | NUMBER {
        $$ = $1;
    }
    | FLOAT_NUMBER {
        $$ = $1;
        printf("in Float_number Parser: FLOAT_NUMBER assigned value = %f\n", $1);
    }
    | ID {
        int idx = findSymbolIndex($1);
        if (idx != -1) {
            if (symbolTable[idx].type == INT_TYPE) {
                $$ = symbolTable[idx].intValue;
            } else if (symbolTable[idx].type == FLOAT_TYPE) {
                $$ = symbolTable[idx].floatValue;
                printf("in ID Parser: FLOAT variable %s = %f\n", $1, symbolTable[idx].floatValue);
            } else if (symbolTable[idx].type == DOUBLE_TYPE) {
                $$ = symbolTable[idx].doubleValue;
            }
        }
    }
    | '(' expression ')' {
        $$ = $2;
    }
    ;

comparison:
    expression EQ expression { $$ = ($1 == $3) ? 1 : 0; }    // 1 if equal, else 0
    | expression NEQ expression { $$ = ($1 != $3) ? 1 : 0; } // 1 if not equal, else 0
    | expression LT expression { $$ = ($1 < $3) ? 1 : 0; }   // 1 if less than, else 0
    | expression GT expression { $$ = ($1 > $3) ? 1 : 0; }   // 1 if greater than, else 0
    | expression LE expression { $$ = ($1 <= $3) ? 1 : 0; }  // 1 if less than or equal, else 0
    | expression GE expression { $$ = ($1 >= $3) ? 1 : 0; }  // 1 if greater than or equal, else 0
    ;


%%

int main() {
    FILE *input = fopen("test_code.txt", "r");  // Open the input file
    if (input) {
        yyin = input;  // Assign the opened file to yyin
        yyparse();      // Start parsing
        fclose(input);  // Close the file after parsing
    } else {
        printf("Error opening test_code.txt\n");
    }
    return 0;
}


int yyerror(char *s) {
    printf("Error: %s\n", s);
    return 0;
}


int findSymbolIndex(char* name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void addSymbol(char* name, DataType type, void* value) {
    int idx = findSymbolIndex(name);
    if (idx == -1) {
        if (symbolCount < MAX_SYMBOLS) {
            symbolTable[symbolCount].name = strdup(name);
            symbolTable[symbolCount].type = type;
            if (value != NULL) {
                if (type == INT_TYPE) {
                    symbolTable[symbolCount].intValue = *(int*)value;
                } else if (type == FLOAT_TYPE) {
                    symbolTable[symbolCount].floatValue = *(float*)value;  // for float type
                     printf("In Symbol Table Assigned float value: %f\n", symbolTable[symbolCount].floatValue);
                } else if (type == DOUBLE_TYPE) {
                    symbolTable[symbolCount].doubleValue = *(double*)value;  // for double type
                }
            }
            symbolCount++;
        } else {
            printf("Symbol table full!\n");
        }
    }
}


int getSymbolValue(char* name) {
    int idx = findSymbolIndex(name);
    if (idx != -1 && symbolTable[idx].type == INT_TYPE) {
        return symbolTable[idx].intValue;
    }
    return 0;
}

float getSymbolFloatValue(char* name) {
    int idx = findSymbolIndex(name);
    if (idx != -1 && symbolTable[idx].type == FLOAT_TYPE) {
        return symbolTable[idx].floatValue;
    }
    return 0.0;
}

double getSymbolDoubleValue(char* name) {
    int idx = findSymbolIndex(name);
    if (idx != -1 && symbolTable[idx].type == DOUBLE_TYPE) {
        return symbolTable[idx].doubleValue;
    }
    return 0.0;
}

char* getSymbolStringValue(char* name) {
    int idx = findSymbolIndex(name);
    if (idx != -1 && symbolTable[idx].type == STRING_TYPE) {
        return symbolTable[idx].stringValue;
    }
    return NULL;
}
