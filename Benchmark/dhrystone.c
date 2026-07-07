void custom_strcpy(char *dst, const char *src) {
    while ((*dst++ = *src++) != '\0');
}

int custom_strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) { s1++; s2++; }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}

#define true  1
#define false 0
#define LOOPS 100

typedef int     Enumeration;
typedef int     One_Thirty;
typedef int     One_Fifty;
typedef char    Capital_Letter;
typedef int     Boolean;
typedef char    String_30 [31];
typedef int     Arr_1_Dim [50];
typedef int     Arr_2_Dim [50] [50];

typedef struct record {
    struct record *Ptr_Comp;
    Enumeration    Discr;
    union {
        struct {
            Enumeration Enum_Comp;
            int         Int_Comp;
            char        Str_Comp [31];
        } var_1;
        struct {
            Enumeration E_Comp_2;
            char        Str_2_Comp [31];
        } var_2;
        struct {
            char        Ch_1_Comp;
            char        Ch_2_Comp;
        } var_3;
    } variant;
} Record_Type, *Record_Pointer;

Record_Pointer  Ptr_Glob, Next_Ptr_Glob;
int             Int_Glob;
Boolean         Bool_Glob;
char            Char_1_Glob, Char_2_Glob;
int             Arr_1_Glob [50];
int             Arr_2_Glob [50] [50];

Record_Type record_1_space;
Record_Type record_2_space;

void Proc_1(Record_Pointer Ptr_Val_Par);
void Proc_2(One_Fifty *Int_Par_Ref);
void Proc_3(Record_Pointer *Ptr_Ref_Par);
void Proc_4(void);
void Proc_5(void);
void Proc_6(Enumeration Enum_Val_Par, Enumeration *Enum_Ref_Par);
void Proc_7(One_Fifty Int_1_Par_Val, One_Fifty Int_2_Par_Val, One_Fifty *Int_Par_Ref);
void Proc_8(Arr_1_Dim Arr_1_Par_Ref, Arr_2_Dim Arr_2_Par_Ref, int Int_1_Par_Val, int Int_2_Par_Val);
Enumeration Func_1(Capital_Letter Ch_1_Par_Val, Capital_Letter Ch_2_Par_Val);
Boolean Func_2(String_30 Str_1_Par_Ref, String_30 Str_2_Par_Ref);
Boolean Func_3(Enumeration Enum_Par_Val);

int main() {
    One_Fifty       Int_1_Loc;
    One_Fifty       Int_2_Loc;
    One_Fifty       Int_3_Loc;
    char            Ch_Index;
    Enumeration     Enum_Loc;
    String_30       Str_1_Loc;
    String_30       Str_2_Loc;
    int             Run_Index;
    int             Number_Of_Runs = LOOPS;

    Next_Ptr_Glob = &record_1_space;
    Ptr_Glob = &record_2_space;

    Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
    Ptr_Glob->Discr                       = 0;
    Ptr_Glob->variant.var_1.Enum_Comp     = 2;
    Ptr_Glob->variant.var_1.Int_Comp      = 40;
    custom_strcpy(Ptr_Glob->variant.var_1.Str_Comp, "DHRYSTONE PROGRAM, SOME STRING");
    custom_strcpy(Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

    Arr_2_Glob [8][7] = 10;

    for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index) {

        Proc_5();
        Proc_4();
        Int_1_Loc = 2;
        Int_2_Loc = 3;
        custom_strcpy(Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
        Enum_Loc = 1;
        Bool_Glob = ! Func_2(Str_1_Loc, Str_2_Loc);
        
        while (Int_1_Loc < Int_2_Loc) {
            Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
            Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
            Int_1_Loc += 1;
        }

        Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
        Proc_1 (Ptr_Glob);
        
        for (Ch_Index = 'A'; Ch_Index <= Char_2_Glob; ++Ch_Index) {
            if (Enum_Loc == Func_1 (Ch_Index, 'C')) {
                Proc_6 (0, &Enum_Loc);
                custom_strcpy(Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
                Int_2_Loc = Run_Index;
                Int_Glob = Run_Index;
            }
        }
        
        Int_2_Loc = Int_2_Loc * Int_1_Loc;
        Int_1_Loc = Int_2_Loc / Int_3_Loc;
        Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
        Proc_2 (&Int_1_Loc);
    }
    
    return 0; 
}

void Proc_1 (Record_Pointer Ptr_Val_Par) {
    Record_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;
    *Ptr_Val_Par->Ptr_Comp = *Ptr_Glob;
    Ptr_Val_Par->variant.var_1.Int_Comp = 5;
    Next_Record->variant.var_1.Int_Comp = Ptr_Val_Par->variant.var_1.Int_Comp;
    Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
    Proc_3 (&Next_Record->Ptr_Comp);
    if (Next_Record->Discr == 0) {
        Next_Record->variant.var_1.Int_Comp = 6;
        Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, &Next_Record->variant.var_1.Enum_Comp);
        Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
        Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, &Next_Record->variant.var_1.Int_Comp);
    } else { *Ptr_Val_Par = *Ptr_Val_Par->Ptr_Comp; }
}

void Proc_2 (One_Fifty *Int_Par_Ref) {
    One_Fifty Int_Loc = Int_Glob + 10;
    Enumeration Enum_Loc = 0;
    if (Char_1_Glob == 'A') {
        Int_Loc -= 1;
        *Int_Par_Ref = Int_Loc - Int_Glob;
        Enum_Loc = 0;
    }
}

void Proc_3 (Record_Pointer *Ptr_Ref_Par) {
    if (Ptr_Glob != 0) *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
    Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
}

void Proc_4 (void) {
    Boolean Bool_Loc = Char_1_Glob == 'A';
    Bool_Glob = Bool_Loc | Bool_Glob;
    Char_2_Glob = 'B';
}

void Proc_5 (void) {
    Char_1_Glob = 'A';
    Bool_Glob = false;
}

void Proc_6 (Enumeration Enum_Val_Par, Enumeration *Enum_Ref_Par) {
    *Enum_Ref_Par = Enum_Val_Par;
    if (! Func_3 (Enum_Val_Par)) *Enum_Ref_Par = 4;
    switch (Enum_Val_Par) {
        case 0: *Enum_Ref_Par = 0; break;
        case 1: if (Int_Glob > 100) *Enum_Ref_Par = 0; else *Enum_Ref_Par = 4; break;
        case 2: *Enum_Ref_Par = 1; break;
        case 3: break;
        case 4: *Enum_Ref_Par = 2; break;
    }
}

void Proc_7 (One_Fifty Int_1_Par_Val, One_Fifty Int_2_Par_Val, One_Fifty *Int_Par_Ref) {
    One_Fifty Int_Loc = Int_1_Par_Val + 2;
    *Int_Par_Ref = Int_2_Par_Val + Int_Loc;
}

void Proc_8 (Arr_1_Dim Arr_1_Par_Ref, Arr_2_Dim Arr_2_Par_Ref, int Int_1_Par_Val, int Int_2_Par_Val) {
    One_Fifty Int_Index;
    One_Fifty Int_Loc = Int_1_Par_Val + 5;
    Arr_1_Par_Ref [Int_Loc] = Int_2_Par_Val;
    Arr_1_Par_Ref [Int_Loc+1] = Arr_1_Par_Ref [Int_Loc];
    Arr_1_Par_Ref [Int_Loc+30] = Int_Loc;
    for (Int_Index = Int_Loc; Int_Index <= Int_Loc+1; ++Int_Index)
        Arr_2_Par_Ref [Int_Loc] [Int_Index] = Int_Loc;
    Arr_2_Par_Ref [Int_Loc] [Int_Loc-1] += 1;
    Arr_2_Par_Ref [Int_Loc+20] [Int_Loc] = Arr_1_Par_Ref [Int_Loc];
    Int_Glob = 5;
}

Enumeration Func_1 (Capital_Letter Ch_1_Par_Val, Capital_Letter Ch_2_Par_Val) {
    Capital_Letter Ch_1_Loc = Ch_1_Par_Val;
    Capital_Letter Ch_2_Loc = Ch_1_Loc;
    if (Ch_2_Loc != Ch_2_Par_Val) return 0;
    else {
        Char_1_Glob = Ch_1_Loc;
        return 1;
    }
}

Boolean Func_2 (String_30 Str_1_Par_Ref, String_30 Str_2_Par_Ref) {
    One_Thirty Int_Loc = 2;
    Capital_Letter Ch_Loc = '\0';
    
    // Đã FIX LỖI Ở ĐÂY: Sửa == 1 thành == 0 để khớp với logic Ident_1 = 0 
    while (Int_Loc <= 2) {
        if (Func_1 (Str_1_Par_Ref[Int_Loc], Str_2_Par_Ref[Int_Loc+1]) == 0) {
            Ch_Loc = 'A';
            Int_Loc += 1;
        }
    }
    
    if (Ch_Loc >= 'W' && Ch_Loc < 'Z') Int_Loc = 7;
    if (Ch_Loc == 'R') return true;
    else {
        if (custom_strcmp (Str_1_Par_Ref, Str_2_Par_Ref) > 0) {
            Int_Loc += 7;
            Int_Glob = Int_Loc;
            return true;
        } else return false;
    }
}

Boolean Func_3 (Enumeration Enum_Par_Val) {
    Enumeration Enum_Loc = Enum_Par_Val;
    if (Enum_Loc == 2) return true;
    else return false;
}