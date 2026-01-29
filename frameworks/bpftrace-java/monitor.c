#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <bpf/libbpf.h>
#include "monitor.skel.h"

FILE *output_file;

int handle_event(void *ctx, void *data, size_t data_sz) {
    fwrite(data, data_sz, 1, output_file);
    fflush(output_file); // Wichtig, um Daten sofort zu sehen
    return 0;
}

int main(int argc, char **argv) {
    struct monitor_bpf *skel;
    struct ring_buffer *rb;
    int pid;

    if (argc < 2) {
        fprintf(stderr, "Nutzung: %s <PID>\n", argv[0]);
        return 1;
    }
    pid = atoi(argv[1]);

    output_file = fopen("kieker.bin", "wb");
    if (!output_file) {
        perror("Fehler beim Öffnen der Ausgabedatei");
        return 1;
    }

    skel = monitor_bpf__open_and_load();
    if (!skel) {
        fprintf(stderr, "Fehler beim Laden des BPF-Skeletts\n");
        return 1;
    }

    // Hier ist die Magie: Wir attachen die Probe explizit an die PID
    // "method_return" muss dem Funktionsnamen in deinem .bpf.c entsprechen (ohne SEC-Präfix)
    skel->links.handle_method_return = bpf_program__attach_usdt(
        skel->progs.handle_method_return, 
        pid, 
        "/usr/lib/jvm/java-17-openjdk-amd64/lib/server/libjvm.so", // Pfad zur libjvm
        "hotspot", 
        "method__return", 
        NULL
    );

    if (!skel->links.handle_method_return) {
        fprintf(stderr, "Fehler beim Attachen der USDT probe an PID %d\n", pid);
        monitor_bpf__destroy(skel);
        return 1;
    }

    printf("Erfolgreich an PID %d gebunden. Schreibe in kieker.bin...\n", pid);

    rb = ring_buffer__new(bpf_map__fd(skel->maps.rb), handle_event, NULL, NULL);
    if (!rb) {
        fprintf(stderr, "Fehler beim Erstellen des Ringbuffers\n");
        return 1;
    }

    while (1) {
        ring_buffer__poll(rb, 100);
    }

    return 0;
}
