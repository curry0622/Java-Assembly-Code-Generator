/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    #define codegen(...) \
        do { \
            for (int i = 0; i < INDENT; i++) { \
                fprintf(fout, "\t"); \
            } \
            fprintf(fout, __VA_ARGS__); \
        } while (0)

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    /* Other global variables */
    FILE *fout = NULL;
    bool HAS_ERROR = false;
    int INDENT = 0;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

    /* For debug */
    bool debug = false;

    /* For symbol table */
    struct entry table[100];
    int curr_lvl = 0;
    int curr_addr = 0;

    /* Symbol table function - you can add new function if needed. */
    static void create_table();
    static void insert_symbol();
    static int lookup_symbol();
    static void dump_table();

    /* Utils */
    static void convert_type();
    static void debug_table();
    static bool check_type_err();
    static bool check_op_err();
    static bool check_redeclare_err();
    static char* type_correction();
    static void check_assign_err();

    /* Code generate */
    static void codegen_print();
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
    int i_val;
    float f_val;
    char *s_val;
    /* ... */
}
/* Token without return */
%token PRINT RETURN IF ELSE FOR WHILE INT FLOAT STRING BOOL TRUE FALSE CONTINUE BREAK VOID
%token ADD SUB MUL QUO REM INC DEC GTR LSS GEQ LEQ EQL NEQ ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN AND OR NOT LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE COMMA SEMICOLON QUOTA

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT POS_INT_LIT NEG_INT_LIT
%token <f_val> FLOAT_LIT POS_FLOAT_LIT NEG_FLOAT_LIT
%token <s_val> STRING_LIT
%token <s_val> IDENT

/* Nonterminal with return, which need to sepcify type */
%type <s_val> Type TypeName
%type <s_val> AddOp MulOp CmpOp UnaryOp AssignOp
%type <s_val> Expression AndExpression CmpExpression AddExpression MulExpression UnaryExpr PrimaryExpr Operand IndexExpr ConversionExpr Literal

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : StatementList {
        if (debug) printf("Program -> StatementList\n");
        dump_table();
    }
;

Type
    : TypeName {
        if (debug) printf("Type -> TypeName\n");
        $$ = $1;
    }
;

TypeName
    : INT {
        if (debug) printf("TypeName -> INT\n");
        $$ = "int";
    }
    | FLOAT {
        if (debug) printf("TypeName -> FLOAT\n");
        $$ = "float";
    }
    | STRING {
        if (debug) printf("TypeName -> STRING\n");
        $$ = "string";
    }
    | BOOL {
        if (debug) printf("TypeName -> BOOL\n");
        $$ = "bool";
    }
;

Expression
    : Expression OR AndExpression {
        if (debug) {
            printf("Expression -> Expression OR AndExpression\n");
        }
        check_type_err($1, "OR", $3);

        printf("OR\n");
        $$ = "bool";
    }
    | AndExpression {
        if (debug) {
            printf("Expression -> AndExpression\n");
        }
        $$ = $1;
    }
;

AndExpression
    : AndExpression AND CmpExpression {
        if (debug) {
            printf("AndExpression -> AndExpression AND CmpExpression\n");
        }
        check_type_err($1, "AND", $3);

        printf("AND\n");
        $$ = "bool";
    }
    | CmpExpression {
        if (debug) {
            printf("AndExpression -> CmpExpression\n");
        }
        $$ = $1;
    }
;

CmpExpression
    : CmpExpression CmpOp AddExpression {
        if (debug) {
            printf("CmpExpression -> CmpExpression CmpOp AddExpression\n");
        }
        check_type_err($1, $2, $3);

        printf("%s\n", $2);
        $$ = "bool";
    }
    | AddExpression {
        if (debug) {
            printf("CmpExpression -> AddExpression\n");
        }
        $$ = $1;
    }
;

AddExpression
    : AddExpression AddOp MulExpression {
        if (debug) {
            printf("AddExpression -> AddExpression AddOp MulExpression\n");
        }
        check_type_err($1, $2, $3);
        printf("%s\n", $2);
        if (strcmp(type_correction($1), "float") == 0 || strcmp(type_correction($3), "float") == 0) {
            $$ = "float";
            if (strcmp($2, "ADD") == 0) {
                codegen("fadd\n");
            }
            if (strcmp($2, "SUB") == 0) {
                codegen("fsub\n");
            }
        } else {
            $$ = "int";
            if (strcmp($2, "ADD") == 0) {
                codegen("iadd\n");
            }
            if (strcmp($2, "SUB") == 0) {
                codegen("isub\n");
            }
        }
    }
    | MulExpression {
        if (debug) {
            printf("AddExpression -> MulExpression\n");
        }
        $$ = $1;
    }
;

MulExpression
    : MulExpression MulOp UnaryExpr {
        if (debug) {
            printf("MulExpression -> MulExpression MulOp UnaryExpr\n");
        }
        check_type_err($1, $2, $3);
        printf("%s\n", $2);
        if (strcmp(type_correction($1), "float") == 0 || strcmp(type_correction($3), "float") == 0) {
            $$ = "float";
            if (strcmp($2, "MUL") == 0) {
                codegen("fmul\n");
            }
            if (strcmp($2, "QUO") == 0) {
                codegen("fdiv\n");
            }
        } else {
            $$ = "int";
            if (strcmp($2, "MUL") == 0) {
                codegen("imul\n");
            }
            if (strcmp($2, "QUO") == 0) {
                codegen("idiv\n");
            }
            if (strcmp($2, "REM") == 0) {
                codegen("irem\n");
            }
        }
    }
    | UnaryExpr {
        if (debug) {
            printf("MulExpression -> UnaryExpr\n");
        }
        $$ = $1;
    }
;

UnaryExpr
    : PrimaryExpr {
        if (debug) printf("UnaryExpr -> PrimaryExpr\n");
        $$ = $1;
    }
    | UnaryOp UnaryExpr {
        if (debug) printf("UnaryExpr -> UnaryOp UnaryExpr\n");
        printf("%s\n", $1);
        $$ = $2;
    }
;

CmpOp
    : EQL {
        if (debug) printf("CmpOp -> EQL\n");
        $$ = "EQL";
    }
    | NEQ {
        if (debug) printf("CmpOp -> NEQ\n");
        $$ = "NEQ";
    }
    | LSS {
        if (debug) printf("CmpOp -> LSS\n");
        $$ = "LSS";
    }
    | LEQ {
        if (debug) printf("CmpOp -> LEQ\n");
        $$ = "LEQ";
    }
    | GTR {
        if (debug) printf("CmpOp -> GTR\n");
        $$ = "GTR";
    }
    | GEQ {
        if (debug) printf("CmpOp -> GEQ\n");
        $$ = "GEQ";
    }
;

AddOp
    : ADD {
        if (debug) printf("ADD\n");
        $$ = "ADD";
    }
    | SUB {
        if (debug) printf("SUB\n");
        $$ = "SUB";
    }
;

MulOp
    : MUL {
        if (debug) printf("MulOp -> MUL\n");
        $$ = "MUL";
    }
    | QUO {
        if (debug) printf("MulOp -> QUO\n");
        $$ = "QUO";
    }
    | REM {
        if (debug) printf("MulOp -> REM\n");
        $$ = "REM";
    }
;

UnaryOp
    : ADD {
        if (debug) printf("UnaryOp -> ADD\n");
        $$ = "POS";
    }
    | SUB {
        if (debug) printf("UnaryOp -> SUB\n");
        $$ = "NEG";
    }
    | NOT {
        if (debug) printf("UnaryOp -> NOT\n");
        $$ = "NOT";
    }
;

PrimaryExpr
    : Operand {
        if (debug) printf("PrimaryExpr -> Operand\n");
        $$ = $1;
    }
    | IndexExpr {
        if (debug) printf("PrimaryExpr -> IndexExpr\n");
        $$ = $1;
    }
    | ConversionExpr {
        if (debug) printf("PrimaryExpr -> ConversionExpr\n");
        $$ = $1;
    }
;

Operand
    : Literal {
        if (debug) printf("Operand -> Literal\n");
        $$ = $1;
    }
    | QUOTA STRING_LIT QUOTA {
        if (debug) printf("Operand -> QUOTA STRING_LIT QUOTA\n");
        codegen("ldc \"%s\"\n", $<s_val>2);
        printf("STRING_LIT %s\n", $<s_val>2);
        $$ = "string_lit";
    }
    | IDENT {
        int addr = lookup_symbol($1);
        if (debug) printf("Operand -> IDENT\n");
        $$ = addr != -1 ? table[addr].type : "undefined";
    }
    | LPAREN Expression RPAREN {
        if (debug) printf("Operand -> LPAREN Expression RPAREN\n");
        $$ = $2;
    }
;

Literal
    : INT_LIT {
        codegen("ldc %d\n", $<i_val>$);
        printf("INT_LIT %d\n", $<i_val>$);
        if (debug) printf("Literal -> INT_LIT\n");
        $$ = "int_lit";
    }
    | FLOAT_LIT {
        codegen("ldc %f\n", $<f_val>$);
        printf("FLOAT_LIT %f\n", $<f_val>$);
        if (debug) printf("Literal -> FLOAT_LIT\n");
        $$ = "float_lit";
    }
    | TRUE {
        codegen("iconst_1\n");
        printf("TRUE\n");
        if (debug) printf("Literal -> TRUE\n");
        $$ = "bool_lit";
    }
    | FALSE {
        codegen("iconst_0\n");
        printf("FALSE\n");
        if (debug) printf("Literal -> FALSE\n");
        $$ = "bool_lit";
    }
    | POS_INT_LIT {
        codegen("ldc %d\n", $<i_val>$);
        printf("INT_LIT %d\n", $<i_val>$);
        printf("POS\n");
        if (debug) printf("Literal -> POS_INT_LIT\n");
        $$ = "int_lit";
    }
    | NEG_INT_LIT {
        codegen("ldc %d\n", $<i_val>$);
        printf("INT_LIT %d\n", $<i_val>$);
        printf("NEG\n");
        if (debug) printf("Literal -> NEG_INT_LIT\n");
        $$ = "int_lit";
    }
    | POS_FLOAT_LIT {
        codegen("ldc %f\n", $<f_val>$);
        printf("FLOAT_LIT %f\n", $<f_val>$);
        printf("POS\n");
        if (debug) printf("Literal -> FLOAT_LIT\n");
        $$ = "float_lit";
    }
    | NEG_FLOAT_LIT {
        codegen("ldc %f\n", $<f_val>$);
        printf("FLOAT_LIT %f\n", $<f_val>$);
        printf("NEG\n");
        if (debug) printf("Literal -> FLOAT_LIT\n");
        $$ = "float_lit";
    }
;

IndexExpr
    : PrimaryExpr LBRACK Expression RBRACK {
        if (debug) printf("IndexExpr -> PrimaryExpr LBRACK Expression RBRACK\n");
        $$ = $1;
    }
;

ConversionExpr
    : LPAREN Type RPAREN Expression {
        if (debug) printf("ConversionExpr -> Type LPAREN Expression RPAREN\n");
        convert_type($4, $2);
        $$ = $2;
    }
;

Statement
    : Statement Statement {
        if (debug) printf("Statement -> Statement Statement\n");
    }
    | ExpressionStmt {
        if (debug) printf("Statement -> ExpressionStmt\n");
    }
    | DeclarationStmt {
        if (debug) printf("Statement -> DeclarationStmt\n");
    }
    | AssignmentStmt {
        if (debug) if (debug) printf("Statement -> AssignmentStmt\n");
    }
    | IncDecStmt {
        if (debug) printf("Statement -> IncDecStmt\n");
    }
    | Block {
        if (debug) printf("Statement -> Block\n");
    }
    | IfStmt {
        if (debug) printf("Statement -> IfStmt\n");
    }
    | WhileStmt {
        if (debug) printf("Statement -> WhileStmt\n");
    }
    | ForStmt {
        if (debug) printf("Statement -> ForStmt\n");
    }
    | PrintStmt {
        if (debug) printf("Statement -> PrintStmt\n");
    }
;

ExpressionStmt
    : Expression SEMICOLON {
        if (debug) printf("ExpressionStmt -> Expression SEMICOLON\n");
    }
;

DeclarationStmt
    : Type IDENT SEMICOLON {
        if (debug) printf("DeclarationStmt -> Type IDENT SEMICOLON\n");
        if (check_redeclare_err($2)) {
            insert_symbol($2, $1, "-");
            codegen("ldc 0\n");
            if (strcmp($1, "int") == 0) {
                codegen("istore %d\n", curr_addr - 1);
            }
            if (strcmp($1, "float") == 0) {
                codegen("fstore %d\n", curr_addr - 1);
            }
        }
    }
    | Type IDENT ASSIGN Expression SEMICOLON {
        if (debug) printf("DeclarationStmt -> Type IDENT ASSIGN Expression SEMICOLON\n");
        if (check_redeclare_err($2)) {
            insert_symbol($2, $1, "-");
            if (strcmp($1, "int") == 0) {
                codegen("istore %d\n", curr_addr - 1);
            }
            if (strcmp($1, "float") == 0) {
                codegen("fstore %d\n", curr_addr - 1);
            }
        }
    }
    | Type IDENT LBRACK Expression RBRACK SEMICOLON {
        if (debug) printf("DeclarationStmt -> Type IDENT LBRACK Expression RBRACK SEMICOLON\n");
        if (check_redeclare_err($2)) {
            insert_symbol($2, "array", $1);
            codegen("newarray %s", $1);
            codegen("astore %d\n", curr_addr - 1);
        }
    }
;

AssignmentStmt
    : AssignmentExpr SEMICOLON {
        if (debug) printf("AssignmentStmt -> AssignmentExpr SEMICOLON\n");
    }
;

AssignmentExpr
    : Expression AssignOp Expression {
        if (debug) printf("AssignmentExpr -> Expression AssignOp Expression\n");
        check_type_err($1, $2, $3);
        check_assign_err($1, $3);
        printf("%s\n", $2);
    }
;

AssignOp
    : ASSIGN {
        if (debug) printf("AssignOp -> ASSIGN\n");
        $$ = "ASSIGN";
    }
    | ADD_ASSIGN {
        if (debug) printf("AssignOp -> ADD_ASSIGN\n");
        $$ = "ADD_ASSIGN";
    }
    | SUB_ASSIGN {
        if (debug) printf("AssignOp -> SUB_ASSIGN\n");
        $$ = "SUB_ASSIGN";
    }
    | MUL_ASSIGN {
        if (debug) printf("AssignOp -> MUL_ASSIGN\n");
        $$ = "MUL_ASSIGN";
    }
    | QUO_ASSIGN {
        if (debug) printf("AssignOp -> QUO_ASSIGN\n");
        $$ = "QUO_ASSIGN";
    }
    | REM_ASSIGN {
        if (debug) printf("AssignOp -> REM_ASSIGN\n");
        $$ = "REM_ASSIGN";
    }
;

IncDecStmt
    : IncDecExpr SEMICOLON {
        if (debug) printf("IncDecStmt -> IncDecExpr SEMICOLON\n");
    }
;

IncDecExpr
    : IDENT INC {
        if (debug) printf("IncDecExpr -> IDENT INC\n");
        int addr = lookup_symbol($1);
        if (addr != -1) {
            if (strcmp(table[addr].type, "int") == 0) {
                codegen("ldc 1\n");
                codegen("iadd\n");
                codegen("istore %d\n", addr);
            }
            if (strcmp(table[addr].type, "float") == 0) {
                codegen("ldc 1.0\n");
                codegen("fadd\n");
                codegen("fstore %d\n", addr);
            }
        }
        printf("INC\n");
    }
    | IDENT DEC {
        if (debug) printf("IncDecExpr -> IDENT DEC\n");
        int addr = lookup_symbol($1);
        if (addr != -1) {
            if (strcmp(table[addr].type, "int") == 0) {
                codegen("ldc 1\n");
                codegen("isub\n");
                codegen("istore %d\n", addr);
            }
            if (strcmp(table[addr].type, "float") == 0) {
                codegen("ldc 1.0\n");
                codegen("fsub\n");
                codegen("fstore %d\n", addr);
            }
        }
        printf("DEC\n");
    }
;

Block
    : BlockLeftBoundary StatementList BlockRightBoundary {
        if (debug) printf("Block -> LBRACE StatementList RBRACE\n");
    }
;

BlockLeftBoundary
    : LBRACE {
        create_table();
    }
;

BlockRightBoundary
    : RBRACE {
        dump_table();
    }
;

StatementList
    : Statement {
        if (debug) printf("StatementList -> Statement\n");
    }
;

IfStmt
    : IF Condition Block {
        if (debug) printf("IfStmt -> IF Condition Block\n");
    }
    | IF Condition Block ELSE IfStmt {
        if (debug) printf("IfStmt -> IF Condition Block ELSE IfStmt");
    }
    | IF Condition Block ELSE Block {
        if (debug) printf("IfStmt -> IF Condition Block ELSE Block\n");
    }
;

Condition
    : Expression {
        if (debug) printf("Condition -> Expression\n");
        if (strcmp(type_correction($1), "bool") != 0) {
            printf("error:%d: non-bool (type %s) used as for condition\n", yylineno + 1, type_correction($1));
        }
    }
;

WhileStmt
    : WHILE LPAREN Condition RPAREN Block {
        if (debug) printf("WhileStmt -> WHILE LPAREN Condition RPAREN Block\n");
    }
;

ForStmt
    : FOR LPAREN ForClause RPAREN Block {
        if (debug) printf("ForStmt -> FOR LPAREN ForClause RPAREN Block\n");
    }
;

ForClause
    : InitStmt SEMICOLON Condition SEMICOLON PostStmt {
        if (debug) printf("ForClause -> InitStmt SEMICOLON Condition SEMICOLON PostStmt\n");
    }
;

InitStmt
    : SimpleExpr {
        if (debug) printf("InitStmt -> SimpleExpr\n");
    }
;

PostStmt
    : SimpleExpr {
        if (debug) printf("PostStmt -> SimpleExpr\n");
    }
;

SimpleExpr
    : AssignmentExpr {
        if (debug) printf("SimpleExpr -> AssignmentExpr\n");
    }
    | Expression {
        if (debug) printf("SimpleExpr -> Expression\n");
    }
    | IncDecExpr {
        if (debug) printf("SimpleExpr -> IncDecExpr\n");
    }
;

PrintStmt
    : PRINT LPAREN Expression RPAREN SEMICOLON {
        if (debug) printf("PrintStmt -> PRINT LPAREN Expression RPAREN SEMICOLON\n");
        printf("PRINT %s\n", type_correction($3));
        codegen_print(type_correction($3));
    }
;

%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

    /* Codegen output init */
    char *bytecode_filename = "hw3.j";
    fout = fopen(bytecode_filename, "w");
    codegen(".source hw3.j\n");
    codegen(".class public Main\n");
    codegen(".super java/lang/Object\n");
    codegen(".method public static main([Ljava/lang/String;)V\n");
    codegen(".limit stack 100\n");
    codegen(".limit locals 100\n");
    INDENT++;

    yyparse();

	printf("Total lines: %d\n", yylineno);

    /* Codegen end */
    codegen("return\n");
    INDENT--;
    codegen(".end method\n");
    fclose(fout);
    fclose(yyin);

    if (HAS_ERROR) {
        remove(bytecode_filename);
    }
    return 0;
}

void create_table() {
    curr_lvl += 1;
}

void insert_symbol(char* name, char* type, char* e_type) {
    table[curr_addr].lineno = yylineno;
    table[curr_addr].lvl = curr_lvl;
    table[curr_addr].addr = curr_addr;
    table[curr_addr].name = name;
    table[curr_addr].type = type;
    table[curr_addr].e_type = e_type;
    curr_addr += 1;
    printf("> Insert {%s} into symbol table (scope level: %d)\n", name, curr_lvl);
}

int lookup_symbol(char* name) {
    for (int lvl = curr_lvl; lvl >= 0; lvl--) {
        for (int i = 0; i < curr_addr; i++) {
            if (
                table[i].lvl == lvl
                && strcmp(table[i].name, name) == 0
            ) {
                printf("IDENT (name=%s, address=%d)\n", name, i);
                if (strcmp(table[i].type, "int") == 0) {
                    codegen("iload %d\n", table[i].addr);
                }
                if (strcmp(table[i].type, "float") == 0) {
                    codegen("fload %d\n", table[i].addr);
                }
                return i;
                // if (strcmp(table[i].type, "array") == 0)
                //     return table[i].e_type;
                // return table[i].type;
            }
        }
    }
    printf("error:%d: undefined: %s\n", yylineno, name);
    return -1;
}

void dump_table() {
    printf("> Dump symbol table (scope level: %d)\n", curr_lvl);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n", "Index", "Name", "Type", "Address", "Lineno", "Element type");
    int index = 0;
    for (int i = 0; i < curr_addr; i++) {
        if (table[i].lvl == curr_lvl) {
            printf("%-10d%-10s%-10s%-10d%-10d%s\n", index++, table[i].name, table[i].type, table[i].addr, table[i].lineno, table[i].e_type);
            table[i].lvl = -1;
        }
    }
    curr_lvl -= 1;
}

void convert_type(char* from, char* to) {
    from = type_correction(from);
    to = type_correction(to);
    char* from_abrv = "";
    char* to_abrv = "";
    if (strcmp(from, "int") == 0) {
        from_abrv = "I";
    } else if (strcmp(from, "float") == 0) {
        from_abrv = "F";
    } else if (strcmp(from, "string") == 0) {
        from_abrv = "S";
    } else {
        from_abrv = "B";
    }
    if (strcmp(to, "int") == 0) {
        to_abrv = "I";
    } else if (strcmp(to, "float") == 0) {
        to_abrv = "F";
    } else if (strcmp(to, "string") == 0) {
        to_abrv = "S";
    } else {
        to_abrv = "B";
    }
    printf("%s to %s\n", from_abrv, to_abrv);
}

void debug_table() {
    printf("> Print Current symbol table (current level: %d)\n", curr_lvl);
    printf("%-10s%-10s%-10s%-10s%-10s%-15s%s\n", "Index", "Name", "Type", "Address", "Lineno", "Element type", "Level");
    int index = 0;
    for (int i = 0; i < curr_addr; i++) {
        printf("%-10d%-10s%-10s%-10d%-10d%-15s%d\n", index++, table[i].name, table[i].type, table[i].addr, table[i].lineno, table[i].e_type, table[i].lvl);
    }
}

bool check_type_err(char* left_type, char* mid_op, char* right_type) {
    left_type = type_correction(left_type);
    right_type = type_correction(right_type);
    if (
        strcmp(left_type, right_type) != 0
        && strcmp(left_type, "undefined") != 0
        && strcmp(right_type, "undefined") != 0
    ) {
        if (
            strcmp(mid_op, "ADD") == 0
            || strcmp(mid_op, "SUB") == 0
            || strcmp(mid_op, "ASSIGN") == 0
        ) {
            printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n", yylineno, mid_op, left_type, right_type);
            return false;
        }
    }
    return check_op_err(left_type, mid_op, right_type);
}

bool check_op_err(char* left_type, char* mid_op, char* right_type) {
    if (strcmp(mid_op, "REM") == 0) {
        if (strcmp(left_type, "int") != 0) {
            printf("error:%d: invalid operation: (operator REM not defined on %s)\n", yylineno, left_type);
            return false;
        }
        if (strcmp(right_type, "int") != 0) {
            printf("error:%d: invalid operation: (operator REM not defined on %s)\n", yylineno, right_type);
            return false;
        }
    }
    if (strcmp(mid_op, "AND") == 0 || strcmp(mid_op, "OR") == 0) {
        if (strcmp(left_type, "bool") != 0) {
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno, mid_op, left_type);
            return false;
        }
        if (strcmp(right_type, "bool") != 0) {
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno, mid_op, right_type);
            return false;
        }
    }
    return true;
}

bool check_redeclare_err(char* name) {
    for(int i = 0; i < curr_addr; i++) {
        /* Look in the same scope */
        if (table[i].lvl == curr_lvl && strcmp(table[i].name, name) == 0) {
            printf("error:%d: %s redeclared in this block. previous declaration at line %d\n", yylineno, name, table[i].lineno);
            return false;
        }
    }
    return true;
}

char* type_correction(char* type) {
    if (strcmp(type, "int_lit") == 0)
        return "int";
    if (strcmp(type, "float_lit") == 0)
        return "float";
    if (strcmp(type, "string_lit") == 0)
        return "string";
    if (strcmp(type, "bool_lit") == 0)
        return "bool";
    return type;
}

void check_assign_err(char* left, char* right) {
    if (
        strcmp(left, "int_lit") == 0
        || strcmp(left, "float_lit") == 0
        || strcmp(left, "string_lit") == 0
        || strcmp(left, "bool_lit") == 0
    ) {
        printf("error:%d: cannot assign to %s\n", yylineno, type_correction(left));
    }
}

/* For code generation */
void codegen_print(char* type) {
    if (strcmp(type, "int") == 0) {
        codegen("getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        codegen("swap\n");
        codegen("invokevirtual java/io/PrintStream/print(I)V\n");
    }
    if (strcmp(type, "float") == 0) {
        codegen("getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        codegen("swap\n");
        codegen("invokevirtual java/io/PrintStream/print(F)V\n");
    }
    if (strcmp(type, "string") == 0) {
        codegen("getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        codegen("swap\n");
        codegen("invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
    }
}
