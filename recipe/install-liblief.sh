#!/bin/bash

ninja -v && ninja -v install

if [[ -d "${PREFIX}"/share/LIEF/examples ]]; then
  rm -rf "${PREFIX}"/share/LIEF/examples/
fi

declare -a OBJDUMP=()
if [[ ${target_platform} == osx-64 ]]; then
  OBJDUMP+=(llvm-objdump)
  V=$(llvm-objdump --version | grep version | cut -d' '  -f5 | cut -d'.' -f1)
  OBJDUMP+=(-t)
  if [[ ${V} == 4 ]]; then
    # Want better matches for these.
    LM="MachO"
    LMBV="BuildVersion"
    LMBTV="BuiltToolVersion"
  else
    OBJDUMP+=(-C)
    LM="typeinfo for LIEF::MachO::"
    LMBV="typeinfo for LIEF::MachO::BuildVersion"
    LMBTV="typeinfo for LIEF::MachO::BuiltToolVersion"
  fi
else
  OBJDUMP+=(objdump)
  OBJDUMP+=(-T)
  OBJDUMP+=(-C)
  LM="typeinfo for LIEF::MachO::"
  LMBV="typeinfo for LIEF::MachO::BuildVersion"
  LMBTV="typeinfo for LIEF::MachO::BuiltToolVersion"
fi

"${OBJDUMP[@]}" ${PREFIX}/lib/libLIEF${SHLIB_EXT} | rg "${LM}"

if ! "${OBJDUMP[@]}" ${PREFIX}/lib/libLIEF${SHLIB_EXT} | rg "${LMBV}"; then
  echo "Failed to find typeinfo for LIEF::MachO::BuildVersion in lib/libLIEF${SHLIB_EXT}"
  exit 1
fi

if ! "${OBJDUMP[@]}" ${PREFIX}/lib/libLIEF${SHLIB_EXT} | rg "${LMBTV}"; then
  echo "Failed to find typeinfo for LIEF::MachO::BuildToolVersion in lib/libLIEF${SHLIB_EXT}"
  exit 2
fi
