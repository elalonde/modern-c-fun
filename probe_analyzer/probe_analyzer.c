#include <stdio.h>
#include <stdlib.h>

struct rec {
    char *name;
    int *data;
};

static struct rec *rec_new(size_t n)
{
    struct rec *r = malloc(sizeof *r);
    if (r == NULL)
        return NULL;
    r->name = malloc(32);
    if (r->name == NULL)
        return NULL;
    r->data = malloc(n * sizeof *r->data);
    if (r->data == NULL) {
        free(r);
        return NULL;
    }
    return r;
}

static void rec_free(struct rec *r)
{
    free(r->data);
    free(r->name);
    free(r);
}

int main(void)
{
    struct rec *r = rec_new(4);
    if (r == NULL)
        return 1;
    rec_free(r);
    free(r->name);
    return 0;
}
