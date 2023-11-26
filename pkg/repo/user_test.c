#include "repo.h"
#include "./../test.h"
#include <stdlib.h>

int TestSignup()
{
    char *fileName = "test-signup";
    system(fmt_Sprintf("touch %s", fileName));

    char *username = "kek";
    char *password = "bau";

    int res = signup(fileName, username, password);
    ASSERT(res == 0);

    res = signup(fileName, username, password);
    ASSERT(res == 1);

    system(fmt_Sprintf("rm %s", fileName));
    return 0;
}

int TestLogin()
{
    char *fileName = "test-login";
    system(fmt_Sprintf("touch %s", fileName));

    char *username = "kek";
    char *password = "bau";

    int res = signup(fileName, username, password);
    ASSERT(res == 0);

    int logged = login(fileName, username, password);
    ASSERT(logged == 0);

    logged = login(fileName, "miao", password);
    ASSERT(logged == 1);

    system(fmt_Sprintf("rm %s", fileName));

    return 0;
}
