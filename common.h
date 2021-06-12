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
};

#endif /* COMMON_H */