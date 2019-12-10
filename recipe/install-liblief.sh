#!/bin/bash

ninja -v && ninja -v install

if [[ -d "${PREFIX}"/share/LIEF/examples ]]; then
  rm -rf "${PREFIX}"/share/LIEF/examples/
fi

objdump -T -C ${PREFIX}/lib/libLIEF.so | rg "typeinfo for LIEF::MachO::"

if ! objdump -T -C ${PREFIX}/lib/libLIEF.so | rg "typeinfo for LIEF::MachO::BuildVersion"; then
  echo "Failed to find typeinfo for LIEF::MachO::BuildVersion in lib/libLIEF.so"
  exit 1
fi

if ! objdump -T -C ${PREFIX}/lib/libLIEF.so | rg "typeinfo for LIEF::MachO::BuildToolVersion"; then
  echo "Failed to find typeinfo for LIEF::MachO::BuildToolVersion in lib/libLIEF.so"
  exit 2
fi
