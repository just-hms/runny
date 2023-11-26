#include "math.h"
#include "./../test.h"

int TestSum()
{
    int a = 3;
    int b = 3;

    int res = sum(a, b);

    ASSERT(res == 6);

    return 0;
}
