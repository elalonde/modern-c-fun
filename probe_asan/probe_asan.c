#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int *v = malloc(8 * sizeof *v);
    if (v == NULL)
        return 1;
    for (int i = 0; i <= 8; i++)
        v[i] = i;
    printf("%d\n", v[3]);
    free(v);
    return 0;
}
