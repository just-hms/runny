#include "repo.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "error.h"

int signup(char *path, char *username, char *password)
{
    FILE *file = fopen(path, "a+"); // Open the file for appending and reading
    if (file == NULL)
        return 1; // Error opening file

    char buffer[256];
    while (fgets(buffer, sizeof(buffer), file))
    {
        // Check if username already exists
        char existingUser[100];
        sscanf(buffer, "%s", existingUser);
        if (strcmp(existingUser, username) == 0)
        {
            fclose(file);
            return 1; // Username already exists
        }
    }

    // Add new user
    fprintf(file, "%s %s\n", username, password);
    fclose(file);
    return 0; // Signup successful
}

int login(char *path, char *username, char *password)
{
    FILE *file = fopen(path, "r"); // Open the file for reading
    if (file == NULL)
        return 1; // Error opening file

    char buffer[256];
    while (fgets(buffer, sizeof(buffer), file))
    {
        char existingUser[100], existingPass[100];
        sscanf(buffer, "%s %s", existingUser, existingPass);
        if (strcmp(existingUser, username) == 0 && strcmp(existingPass, password) == 0)
        {
            fclose(file);
            return 0; // Login successful
        }
    }

    fclose(file);
    return 1; // Login failed
}
