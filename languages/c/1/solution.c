#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAXCHAR 1000
int main()
{
  char *line;
  int value = 0;
  int result = 0;
  FILE *fp;

  if ((fp = fopen("input.txt", "r")) == NULL)
  {
    printf("Error! opening file\n");
    // Program exits if file pointer returns NULL.
    exit(1);
  }

  while (fgets(line, MAXCHAR, fp) != NULL)
  {
    value = atoi(line);
    result = result + value;
  }

  fclose(fp);

  printf("Result: %i\n", result);

  return 0;
}