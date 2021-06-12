#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

struct entry {
  int lineno;
  int lvl;
  int addr;
  char* name;
  char* type;
  char* e_type;
  int i_val;
  float f_val;
  char* s_val;
  bool b_val;
};

struct expr_val {
  int addr;
  char* type;
  int i_val;
  float f_val;
  char* s_val;
  bool b_val;
};

#endif /* COMMON_H */