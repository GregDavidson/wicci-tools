#include <postgres.h>

#define LONG_TYPE long
#define SHOW_LONG(expression) show_long(#expression, ( (LONG_TYPE) (expression) ) )
#define SHOW_SIZE(expression) SHOW_LONG( sizeof (expression) )

void show_long(const char *expression, LONG_TYPE value) {
  printf("%s = %ld\n", expression, value);
}


int main(void) {
  SHOW_LONG(VARHDRSZ);
  SHOW_SIZE(text *);
  return 0;
}
