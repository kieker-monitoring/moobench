// SPDX-License-Identifier: GPL-2.0
#include <stdbool.h>

#ifdef __TARGET_ARCH_arm64
struct user_pt_regs { unsigned long long regs[31]; unsigned long long sp; unsigned long long pc; unsigned long long pstate; };
struct pt_regs { union { struct user_pt_regs user_regs; struct { unsigned long long regs[31]; unsigned long long sp; unsigned long long pc; unsigned long long pstate; }; }; unsigned long long orig_x0; unsigned long long syscallno; unsigned long long orig_addr_limit; unsigned long long pmr_save; unsigned long long stackframe[2]; unsigned long long lockdep_hardirqs; unsigned long long exit_rcu; };
#endif

#ifdef __TARGET_ARCH_x86
struct pt_regs { unsigned long r15; unsigned long r14; unsigned long r13; unsigned long r12; unsigned long rbp; unsigned long rbx; unsigned long r11; unsigned long r10; unsigned long r9; unsigned long r8; unsigned long rax; unsigned long rcx; unsigned long rdx; unsigned long rsi; unsigned long rdi; unsigned long orig_rax; unsigned long rip; unsigned long cs; unsigned long eflags; unsigned long rsp; unsigned long ss; };
#endif

#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/usdt.bpf.h>

// Key for storing start times
struct event_key {
    __u64 tid;
    __u64 depth;
};

struct method_entry {
    __u64 start_time;
};

struct method_event {
    __u64 pid;
    __u64 tid;
    __u64 entry_time;
    __u64 exit_time;
    __u64 depth;
    char method_name[64];
};

// --- MAPS ---

// Map 1: Tracks current recursion depth for each thread
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 256);
    __type(key, __u64);
    __type(value, __u64);
} depth_map SEC(".maps");

// Map 2: Stores start times
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 256);
    __type(key, struct event_key);
    __type(value, struct method_entry);
} method_entries SEC(".maps");

// Map 3: Ringbuffer for output
struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 4 * 1024 * 1024);
} events SEC(".maps");


// --- HELPERS ---

static __always_inline int is_monitored_class(char *class_name) {
    // Only trace target
    char buf[41] = {};
    if (bpf_probe_read_user(buf, sizeof(buf), class_name) < 0) return 0;
    const char target[] = "moobench/application/MonitoredClassSimple";
    return __builtin_memcmp(buf, target, 41) == 0;
}

SEC("usdt")
int BPF_USDT(handle_method_entry, long thread_id, char *class_name, int class_len, char *method_name, int method_len)
{
    // Skip bpf_probe_read_user for non-target classes
    if (class_len != 41) return 0;

    __u64 pid_tgid = bpf_get_current_pid_tgid();
    __u64 tid = pid_tgid & 0xFFFFFFFF;

    // 1. Only trace target
    if (!is_monitored_class(class_name)) return 0;

    // 2. Increment depth
    __u64 depth = 0;
    __u64 *depth_ptr = bpf_map_lookup_elem(&depth_map, &tid);
    if (depth_ptr) {
        depth = *depth_ptr + 1;
    } else {
        depth = 1;
    }
    bpf_map_update_elem(&depth_map, &tid, &depth, BPF_ANY);

    // 3. Stire start time
    struct event_key key = {};
    key.tid = tid;
    key.depth = depth;

    struct method_entry entry = {};
    entry.start_time = bpf_ktime_get_ns();

    bpf_map_update_elem(&method_entries, &key, &entry, BPF_ANY);

    return 0;
}

SEC("usdt")
int BPF_USDT(handle_method_return, long thread_id, char *class_name, int class_len, char *method_name, int method_len)
{
    if (class_len != 41) return 0;

    __u64 pid_tgid = bpf_get_current_pid_tgid();
    __u64 tid = pid_tgid & 0xFFFFFFFF;
    __u64 pid = pid_tgid >> 32;

    // 1. Only trace target
    if (!is_monitored_class(class_name)) return 0;

    // 2. Get current depth
    __u64 *depth_ptr = bpf_map_lookup_elem(&depth_map, &tid);
    if (!depth_ptr || *depth_ptr == 0) return 0;
    __u64 depth = *depth_ptr;

    // 3. Retrieve start time
    struct event_key key = {};
    key.tid = tid;
    key.depth = depth;

    struct method_entry *entry = bpf_map_lookup_elem(&method_entries, &key);

    // 4. Decrement depth
    __u64 new_depth = depth - 1;
    if (new_depth == 0) {
        bpf_map_delete_elem(&depth_map, &tid);
    } else {
        bpf_map_update_elem(&depth_map, &tid, &new_depth, BPF_ANY);
    }

    if (!entry) return 0; // Missed entry

    // 5. Record exit time & cleanup
    __u64 exit_time = bpf_ktime_get_ns();
    __u64 entry_time = entry->start_time;
    bpf_map_delete_elem(&method_entries, &key);

    // 6. Submit event
    struct method_event *event = bpf_ringbuf_reserve(&events, sizeof(*event), 0);
    if (!event) return 0;

    event->pid = pid;
    event->tid = tid;
    event->entry_time = entry_time;
    event->exit_time = exit_time;
    event->depth = depth;
    // Read only as many bytes as needed
    __u32 name_len = ((__u32)method_len < sizeof(event->method_name))
                         ? (__u32)method_len
                         : sizeof(event->method_name) - 1;
    bpf_probe_read_user(event->method_name, name_len, method_name);

    bpf_ringbuf_submit(event, 0);
    return 0;
}

char LICENSE[] SEC("license") = "GPL";