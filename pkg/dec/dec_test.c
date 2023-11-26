#include "dec.h"
#include "./../test.h"
#include "./../math/math.h"

int TestDec()
{
    int res = dec(sum(1, 2));
    ASSERT(res == 2);
    return 0;
}
