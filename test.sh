#!/bin/bash

template='
#include <stdio.h>
#include <pthread.h>

int testsResult = 0;
// Declare the mutex;
pthread_mutex_t mutex; 

typedef struct {
    int (*testFunc)();
    char *funcName;
} TestStruct;

// Function to run tests
void *run_test(void *arg)
{
    TestStruct *test = (TestStruct *)arg; // Cast argument to TestStruct pointer
    int res = test->testFunc();
    pthread_mutex_lock(&mutex);
    testsResult = testsResult || res;
    pthread_mutex_unlock(&mutex);

	if (res == 0) {
        printf("%-20s\t[OK]\n", test->funcName);
    } else {
        fprintf(stderr, "\033[31m%-20s\t[FAILED]\033[0m\n", test->funcName);
    }
    return NULL;
}

#define NUM_TESTS {@NUM_TESTS}
#define NUM_THREADS {@NUM_THREADS}

{@INCLUDES}

int main()
{
	pthread_t threads[NUM_THREADS];
	pthread_mutex_init(&mutex, NULL); // Initialize the mutex	

	TestStruct tests[NUM_TESTS] = {{@TESTS}};
	int threadIndex = 0;

	// Create and join threads
	for (int i = 0; i < NUM_TESTS; i++)
	{
		if (pthread_create(&threads[threadIndex], NULL, run_test, &tests[i]))
		{
			fprintf(stderr, "Error creating thread\n");
			return 1;
		}

		if (++threadIndex >= NUM_THREADS)
		{
			// Wait for threads to finish
			for (int j = 0; j < NUM_THREADS; j++)
			{
				pthread_join(threads[j], NULL);
			}
			threadIndex = 0;
		}
	}

	// Join any remaining threads
	for (int i = 0; i < threadIndex; i++)
	{
		pthread_join(threads[i], NULL);
	}

	pthread_mutex_destroy(&mutex); // Destroy the mutex after use
	return testsResult;
}
'

# Initialize arrays for includes and function calls
includes=()
calls=()

# Walking through directories and files
while IFS= read -r path; do
    abs_path=$(realpath "$path")

    # Append to includes
    includes+=("#include \"$abs_path\"")

    # Read lines from file
    while IFS= read -r line; do
        # Check for function names
        if [[ "$line" =~ Test[a-zA-Z0-9_]+\(\) ]]; then
            s=$(echo "$line" | sed -e 's/int //' -e 's/().*//')
            calls+=("{$s,\"$s\"}")
        fi
    done < "$path"
done < <(find . -type f -name '*_test.c')

# Replace placeholders in the template
num_tests=${#calls[@]}
num_threads=2
tests=$(IFS=, ; echo "${calls[*]}")
includes=$(IFS=$'\n' ; echo "${includes[*]}")

# Update the template
template=${template//'{@NUM_TESTS}'/$num_tests}
template=${template//'{@NUM_THREADS}'/$num_threads}
template=${template//'{@TESTS}'/$tests}
template=${template//'{@INCLUDES}'/$includes}

# Print the updated template
echo "$template" | while IFS= read -r line; do
    echo "$line"
done

