#!/bin/bash

#
# Makes the RAPL energy counters readable for the current session,
# so energy can be measured (ENERGY=true) without running MooBench as root.
# The permission is reset on reboot.
#

RAPL_FILE="/sys/class/powercap/intel-rapl:0/energy_uj"

if [ ! -e "${RAPL_FILE}" ]; then
  echo "RAPL is not available on this machine (${RAPL_FILE} does not exist)."
  exit 1
fi

if [ -r "${RAPL_FILE}" ]; then
  echo "RAPL counters are already readable."
  exit 0
fi

echo "Energy measurement needs read access to the RAPL counters."
echo "This requires sudo once; please enter your password if asked."

if sudo chmod o+r /sys/class/powercap/intel-rapl:*/energy_uj; then
  echo "RAPL counters are now readable (until the next reboot)."
else
  echo "Could not change RAPL permissions."
  exit 1
fi