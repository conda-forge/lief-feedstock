#!/bin/bash

declare -a CMAKE_EXTRA_ARGS
if [[ ${target_platform} == osx-64 ]]; then
  CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
elif [[ ${target_platform} == linux-ppc64le ]]; then
  CMAKE_EXTRA_ARGS+=(-DLIEF_LOGGING=OFF)
fi
if [[ ${target_platform} == linux-* ]]; then
  # TODO: remove this when lief's internal pybind is updated (with lief=0.10.0 probably)
  export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations"
  export CFLAGS="${CFLAGS} -Wno-deprecated-declarations"
  # export LDFLAGS="${LDFLAGS} -Wl,--trace -Wl,--cref -Wl,--trace-symbol,_ZTIN4LIEF5MachO16BuildToolVersionE"
  export LDFLAGS="${LDFLAGS} -Wl,--trace-symbol,_ZTIN4LIEF5MachO16BuildToolVersionE -Wl,--trace-symbol,_ZTIN4LIEF5MachO12BuildVersionE"
fi

cmake . -LAH -G "Ninja"               \
  -DLIEF_VERSION_MAJOR=0              \
  -DLIEF_VERSION_MINOR=10             \
  -DLIEF_VERSION_PATCH=1              \
  -DCMAKE_BUILD_TYPE="Release"        \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"  \
  -DCMAKE_SKIP_RPATH=ON               \
  -DCMAKE_AR="${AR}"                  \
  -DCMAKE_LINKER="${LD}"              \
  -DCMAKE_NM="${NM}"                  \
  -DCMAKE_OBJCOPY="${OBJCOPY}"        \
  -DCMAKE_OBJDUMP="${OBJDUMP}"        \
  -DCMAKE_RANLIB="${RANLIB}"          \
  -DCMAKE_STRIP="${STRIP}"            \
  -DBUILD_SHARED_LIBS=ON              \
  -DLIEF_PYTHON_API=OFF               \
  -DLIEF_INSTALL_PYTHON=OFF           \
  "${CMAKE_EXTRA_ARGS[@]}"

if [[ ! $? ]]; then
  echo "configure failed with $?"
  exit 1
fi
