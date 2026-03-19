ARCH := $(shell uname -m)
ifeq ($(ARCH),x86_64)
  ARCH_FLAG  := x86
  GNU_ARCH   := x86_64-linux-gnu
else
  ARCH_FLAG  := arm64
  GNU_ARCH   := aarch64-linux-gnu
endif

BPF_SRC := java_tracer_usdt.bpf.c
BPF_OBJ := java_tracer_usdt.bpf.o
CPP_SRC := java_tracer_usdt.cpp
BIN     := java_tracer_usdt

.PHONY: all clean symlink

all: symlink $(BPF_OBJ) $(BIN)

symlink:
	@if [ ! -e /usr/include/asm ]; then \
		echo "Creating asm symlink..."; \
		sudo ln -sf /usr/include/$(GNU_ARCH)/asm /usr/include/asm; \
	fi

$(BPF_OBJ): $(BPF_SRC)
	clang -g -O2 -target bpf -D__TARGET_ARCH_$(ARCH_FLAG) \
		-c $< -o $@

$(BIN): $(CPP_SRC)
	g++ -o $@ $< -lbpf -lelf -lz
	sudo setcap cap_bpf,cap_perfmon=eip $@

clean:
	rm -f $(BPF_OBJ) $(BIN)
