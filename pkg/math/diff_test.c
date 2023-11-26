#include "math.h"
#include "./../test.h"

int TestDiff()
{
    int a = 3;
    int b = 3;
    int res = diff(a, b);
    ASSERT(res == 0);

    a = 4;
    b = 2;
    res = diff(a, b);
    ASSERT(res == 2);

    return 0;
}
