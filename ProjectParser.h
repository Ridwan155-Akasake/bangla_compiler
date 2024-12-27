#ifndef PROJECTPARSER_H
#define PROJECTPARSER_H

// Enum for data types
typedef enum { INT_TYPE, FLOAT_TYPE, DOUBLE_TYPE, STRING_TYPE } DataType;

// Symbol table entry structure
typedef struct Symbol {
    char* name;
    DataType type;
    union {
        int intValue;
        float floatValue;
        double doubleValue;
        char* stringValue;
    };
} Symbol;

// Function prototypes
int findSymbolIndex(char* name);
void addSymbol(char* name, DataType type, void* value);
int getSymbolValue(char* name);
float getSymbolFloatValue(char* name);
double getSymbolDoubleValue(char* name);
char* getSymbolStringValue(char* name);

#endif // PROJECTPARSER_H
