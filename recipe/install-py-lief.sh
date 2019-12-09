#!/bin/bash

declare -a CMAKE_EXTRA_ARGS
if [[ ${target_platform} =~ linux-* ]]; then
  echo "Nothing special for linux"
elif [[ ${target_platform} == osx-64 ]]; then
  CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
else
  echo "target_platform not known: ${target_platform}"
  exit 1
fi

cmake . -LAH -G "Ninja"  \
  -DCMAKE_BUILD_TYPE="Release"  \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"  \
  -DCMAKE_INSTALL_LIBDIR=lib  \
  -DCMAKE_SKIP_RPATH=ON  \
  -DCMAKE_AR="${AR}"  \
  -DCMAKE_LINKER="${LD}"  \
  -DCMAKE_NM="${NM}"  \
  -DCMAKE_OBJCOPY="${OBJCOPY}"  \
  -DCMAKE_OBJDUMP="${OBJDUMP}"  \
  -DCMAKE_RANLIB="${RANLIB}"  \
  -DCMAKE_STRIP="${STRIP}"  \
  -DLIEF_PYTHON_API=ON  \
  -DLIEF_INSTALL_PYTHON=ON  \
  -DPYTHON_EXECUTABLE="${PYTHON}"  \
  -DPYTHON_INCLUDE_DIR:PATH=$(${PYTHON} -c 'from sysconfig import get_paths; print(get_paths()["include"])')  \
  -DPYTHON_LIBRARIES="${PREFIX}"/lib/libpython${PY_VER}.dylib  \
  -DPYTHON_LIBRARY="${PREFIX}"/lib/libpython${PY_VER}.dylib  \
  -DPYTHON_EXECUTABLE="${PREFIX}"/bin/python  \
  -DPYTHON_VERSION=${PY_VER}  \
  "${CMAKE_EXTRA_ARGS[@]}"

if [[ ! $? ]]; then
  echo "configure failed with $?"
  exit 1
fi

# cmake --build . --target pyLIEF
# cmake --build . --target install
ninja -v pyLIEF && ninja -v install
ext_suffix="$( ${PYTHON} -c 'from sysconfig import get_config_var as get; print(get("EXT_SUFFIX") or get("SO"))' )"
mv api/python/lief.so ${SP_DIR}/lief${ext_suffix}
if [[ ${target_platform} == osx-64 ]]; then
  ${INSTALL_NAME_TOOL:-install_name_tool} -id @rpath/_pylief${ext_suffix} ${SP_DIR}/lief${ext_suffix}
fi
set -e
${PYTHON} -c "import lief"

if [[ -d "${PREFIX}"/share/LIEF/examples ]]; then
  rm -rf "${PREFIX}"/share/LIEF/examples/
fi
