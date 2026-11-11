#! /bin/bash

# build benchmark with and without instrumentation

gcc benchmark.c -c -I /usr/include/glib-2.0/ -I /usr/lib/x86_64-linux-gnu/glib-2.0/include/

# no instrumentation

gcc monitored_application.c -c
gcc benchmark.o monitored_application.o -o benchmark -l glib-2.0 -g

# instrumentation

# get kieker for C
BASE=`pwd`
MONITORING_LIB_DIR="${BASE}/monitoring"
mkdir "${MONITORING_LIB_DIR}"
cd "${MONITORING_LIB_DIR}"

git clone https://github.com/kieker-monitoring/kieker-lang-pack-c.git
cd kieker-lang-pack-c/source/

libtoolize
aclocal
autoconf
automake --add-missing

./configure --prefix="${MONITORING_LIB_DIR}"
make
make install

cd "${BASE}"

gcc monitored_application.c -c -finstrument-functions

gcc benchmark.o monitored_application.o -o benchmark -l glib-2.0 -g -l kieker -L "${MONITORING_LIB_DIR}/lib/" -o benchmark-instr -finstrument-functions -finstrument-functions-exclude-file-list=benchmark.c

# end

