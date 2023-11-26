#!/bin/bash

template='
#include <stdio.h>
#include <pthread.h>

// Function to run tests
void *run_test(void *arg)
{
	int (*testFunc)() = arg; // Cast argument to a function pointer
	int res = testFunc();
	printf("%-20s\t[%s]\n", "Test", (res == 0) ? "OK" : "FAILED");
	return NULL;
}

#define NUM_TESTS {@NUM_TESTS}
#define NUM_THREADS {@NUM_THREADS}


{@INCLUDES}

int main()
{
	pthread_t threads[NUM_THREADS];

	int (*tests[NUM_TESTS])() = {{@TESTS}};
	int threadIndex = 0;

	// Create and join threads
	for (int i = 0; i < NUM_TESTS; i++)
	{
		if (pthread_create(&threads[threadIndex], NULL, run_test, tests[i]))
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

	return 0;
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
            calls+=("$s")
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

