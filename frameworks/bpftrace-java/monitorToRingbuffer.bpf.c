#include <stdbool.h>            // Fix für 'bool' error
#include <linux/ptrace.h>       // Fix für 'struct pt_regs'
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/usdt.bpf.h>

struct event {
    unsigned long long trace_id;
    unsigned long long start_time;
    unsigned long long end_time;
    unsigned int eoi;
    unsigned int ess;
    unsigned int method_id;
};

struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 16 * 1024 * 1024);
} rb SEC(".maps");

SEC("usdt")
int BPF_USDT(handle_method_return) { // Nutze BPF_USDT Makro!
    struct event *e;

    e = bpf_ringbuf_reserve(&rb, sizeof(*e), 0);
    if (!e) return 0;

    e->trace_id = bpf_get_current_pid_tgid() >> 32;
    e->start_time = 0; 
    e->end_time = bpf_ktime_get_ns();
    e->eoi = 0; 
    e->ess = 0;
    e->method_id = 1;

    bpf_ringbuf_submit(e, 0);
    return 0;
}
