#include <iostream>
#include <string>
#include <csignal>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <sys/resource.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <errno.h>

using std::string;
using std::to_string;

#define LOG(fmt, ...) fprintf(stderr, "[tracer] " fmt "\n", ##__VA_ARGS__)

static string get_bpf_obj_path() {
    char exe_path[4096] = {};
    ssize_t len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
    if (len > 0) {
        string path(exe_path, len);
        size_t last_slash = path.rfind('/');
        if (last_slash != string::npos)
            return path.substr(0, last_slash + 1) + "java_tracer_usdt.bpf.o";
    }
    return "java_tracer_usdt.bpf.o";
}

struct method_event {
    uint64_t pid;
    uint64_t tid;
    uint64_t entry_time;
    uint64_t exit_time;
    uint64_t depth;
    char method_name[64];
};

static volatile sig_atomic_t exiting = 0;
static FILE *global_out = nullptr;
static uint8_t write_buf[8192];
static size_t buf_pos = 0;

static void sig_handler(int sig) {
    exiting = 1;
}

static inline void flush_buf() {
    if (buf_pos > 0 && global_out) {
        fwrite(write_buf, 1, buf_pos, global_out);
        buf_pos = 0;
    }
}

static int handle_event(void *ctx, void *data, size_t data_sz) {
    const struct method_event *e = static_cast<const struct method_event*>(data);

    if (global_out) {
        // Buffer binary events flush when full
        if (buf_pos + sizeof(*e) > sizeof(write_buf)) {
            flush_buf();
        }
        memcpy(write_buf + buf_pos, e, sizeof(*e));
        buf_pos += sizeof(*e);
    }
    return 0;
}

static string find_libjvm_path(pid_t pid) {
    string maps_file = "/proc/" + to_string(pid) + "/maps";
    FILE *fp = fopen(maps_file.c_str(), "r");
    if (!fp) {
        LOG("ERROR: Failed to open maps file: %s", strerror(errno));
        return "";
    }

    char line[1024];
    string libjvm_path;

    while (fgets(line, sizeof(line), fp)) {
        if (strstr(line, "libjvm.so")) {
            char *p = strchr(line, '/');
            if (p) {
                char *newline = strchr(p, '\n');
                if (newline) *newline = '\0';
                libjvm_path = string(p);
                break;
            }
        }
    }
    fclose(fp);
    return libjvm_path;
}

int main(int argc, char **argv) {
    LOG("Tracer starting...");
    if (argc < 2) {
        LOG("Usage: %s <PID> [options]", argv[0]);
        return 1;
    }
    
    pid_t target_pid = std::stoi(argv[1]);
    string output_file = "ebpf_trace.bin";
    string mode = "write";

    for (int i = 2; i < argc; i++) {
        if (strncmp(argv[i], "--output=", 9) == 0) output_file = string(argv[i] + 9);
        if (strncmp(argv[i], "--mode=",   7) == 0) mode        = string(argv[i] + 7);
    }

    LOG("Target PID: %d", target_pid);
    LOG("Mode: %s", mode.c_str());

    if (kill(target_pid, 0) != 0) {
        LOG("ERROR: PID %d does not exist or permission denied.", target_pid);
        return 1;
    }

    if (mode == "write") {
        LOG("Output File: %s", output_file.c_str());
        global_out = fopen(output_file.c_str(), "wb");
        if (!global_out) {
            LOG("ERROR: Could not open output file!");
            return 1;
        }
    } else {
        LOG("Count mode: events consumed but not written to disk.");
    }

    string libjvm_path = find_libjvm_path(target_pid);
    if (libjvm_path.empty()) {
        LOG("CRITICAL ERROR: Could not find libjvm.so in process maps.");
        return 1;
    }
    
    string bpf_obj_path = get_bpf_obj_path();
    LOG("Loading BPF object: %s", bpf_obj_path.c_str());
    struct bpf_object *obj = bpf_object__open_file(bpf_obj_path.c_str(), nullptr);
    if (!obj) {
        LOG("ERROR: Failed to open BPF object.");
        return 1;
    }

    if (bpf_object__load(obj)) {
        LOG("ERROR: Failed to load BPF object (Verifier/Map error).");
        return 1;
    }
    
    struct bpf_program *entry_prog = bpf_object__find_program_by_name(obj, "handle_method_entry");
    struct bpf_program *exit_prog = bpf_object__find_program_by_name(obj, "handle_method_return");
    
    if (!entry_prog || !exit_prog) {
        LOG("ERROR: Could not find BPF programs.");
        return 1;
    }

    LOG("Attaching USDT probes...");
    struct bpf_link *l1 = bpf_program__attach_usdt(entry_prog, target_pid, libjvm_path.c_str(), "hotspot", "method__entry", nullptr);
    if (!l1) {
        LOG("ERROR: Failed to attach method__entry: %s", strerror(errno));
    } else {
        LOG("Attached method__entry");
    }

    struct bpf_link *l2 = bpf_program__attach_usdt(exit_prog, target_pid, libjvm_path.c_str(), "hotspot", "method__return", nullptr);
    if (!l2) {
        LOG("ERROR: Failed to attach method__return: %s", strerror(errno));
    } else {
        LOG("Attached method__return");
    }
    
    int events_fd = bpf_map__fd(bpf_object__find_map_by_name(obj, "events"));
    struct ring_buffer *rb = ring_buffer__new(events_fd, handle_event, nullptr, nullptr);
    if (!rb) {
        LOG("ERROR: Failed to create ring buffer.");
        return 1;
    }
    
    signal(SIGINT, sig_handler);
    signal(SIGTERM, sig_handler);
    
    LOG("Initialization complete. Entering event loop...");
    while (!exiting) {
        int err = ring_buffer__poll(rb, 100);
        if (err == -EINTR) break;
        
        if (kill(target_pid, 0) != 0) {
            LOG("Target process died. Exiting.");
            break; 
        }
    }
    
    flush_buf();
    if (global_out) fclose(global_out);
    ring_buffer__free(rb);
    bpf_object__close(obj);
    return 0;
}