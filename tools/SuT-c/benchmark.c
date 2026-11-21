#include "monitored_application.h"
#include <glib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

gchar* get_value_or_stop(GKeyFile *key_file, char* section_name, char* key_name) {
    GError *error = NULL;

    // Read a string value from [SectionName] with KeyName
    gchar *val = g_key_file_get_string(key_file, section_name, key_name, &error);
    if (error == NULL) {
        return val;
    } else {
        g_printerr("Error %s\n", error->message);
        g_error_free(error);
        exit(1);
    }
}

bool make_bool(gchar* label) {
    return strcmp(label, "True") == 0;
}

int main(int argc, char *argv[]) {
    struct timespec res;

    if (argc < 1) {
        printf("Path to the benchmark configuration file was not provided.");
        exit(1);
    }

    GKeyFile *key_file = g_key_file_new();
    GError *error = NULL;

    // Load the INI/key file
    if (!g_key_file_load_from_file(key_file, argv[1], G_KEY_FILE_NONE, &error)) {
        g_printerr("Error loading file: %s\n", error->message);
        g_error_free(error);
        g_key_file_free(key_file);
        exit(1);
    }

    long total_calls = g_ascii_strtoll(get_value_or_stop(key_file, "Benchmark", "total_calls"), NULL, 10);
    long recursion_depth = g_ascii_strtoll(get_value_or_stop(key_file, "Benchmark", "recursion_depth"), NULL, 10);
    long method_time = g_ascii_strtoll(get_value_or_stop(key_file, "Benchmark","method_time"), NULL, 10);
    gchar* output_filename = get_value_or_stop(key_file, "Benchmark", "output_filename");

    printf("Writing results to: %s\n", output_filename);
    printf("Starting execution: %ld calls.\n", total_calls);

    FILE* output_file = fopen(output_filename, "w");
    int thread_id = 0;
    long duration;

    for (int i=0; i < total_calls; i++) {
        clock_gettime(CLOCK_REALTIME,&res);
        long start_ns = res.tv_nsec;

        monitored_method(method_time, recursion_depth);

        clock_gettime(CLOCK_REALTIME,&res);
        long stop_ns = res.tv_nsec;

        duration = stop_ns - start_ns;
        // correct for clock overflow
        if (duration < 0)
            duration = 1000000000 + duration;

        if (i % 100000 == 0 && i > 0) {
            printf("Call %d: %ld ns", i, duration);
        }

        fprintf(output_file, "%d;%ld\n", thread_id, duration);
    }

    fclose(output_file);

    printf("Benchmark finished.\n");
}
