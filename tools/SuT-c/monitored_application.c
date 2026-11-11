#include <time.h>

struct timespec res;

long monitored_method(long method_time, long rec_depth) {
    if (rec_depth > 1) {
        return monitored_method(method_time, rec_depth-1);
    } else {
        clock_gettime(CLOCK_REALTIME,&res);
        long exit_time = res.tv_nsec + method_time;
        long current_time = 0;
        while (current_time <= exit_time) {
            clock_gettime(CLOCK_REALTIME,&res);
            current_time = res.tv_nsec;
        }
        return current_time;
    }
}
