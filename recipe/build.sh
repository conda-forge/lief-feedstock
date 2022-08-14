#!/bin/bash

set -exuo pipefail

if [[ ${target_platform} == osx-64 ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
elif [[ ${target_platform} == linux-ppc64le ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DLIEF_LOGGING=OFF"
fi

# Please keep this comment around. It may help if this problem reoccurs.
# if [[ ${target_platform} =~ linux-* ]]; then
#   # TODO: remove this when lief's internal pybind is updated (with lief=0.10.0 probably)
#   export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations"
#   export CFLAGS="${CFLAGS} -Wno-deprecated-declarations"
#   # export LDFLAGS="${LDFLAGS} -Wl,--trace -Wl,--cref -Wl,--trace-symbol,_ZTIN4LIEF5MachO16BuildToolVersionE"
#   # export LDFLAGS="${LDFLAGS} -Wl,--trace-symbol,_ZTIN4LIEF5MachO16BuildToolVersionE -Wl,--trace-symbol,_ZTIN4LIEF5MachO12BuildVersionE"
# fi

mkdir build || true
pushd build

cmake ${CMAKE_ARGS} -LAH -G "Ninja"  \
  -DCMAKE_BUILD_TYPE="Release"  \
  -DBUILD_STATIC_LIBS=OFF  \
  -DBUILD_SHARED_LIBS=ON  \
  -DCMAKE_SKIP_RPATH=ON  \
  -DLIEF_PYTHON_API=OFF  \
  -DLIEF_INSTALL_PYTHON=OFF  \
  -DLIEF_EXTERNAL_PYBIND11=ON \
  -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON \
  ..

if [[ ! $? ]]; then
  echo "configure failed with $?"
  exit 1
fi

popd
