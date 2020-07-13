#!/bin/bash

set -x

declare -a CMAKE_EXTRA_ARGS
if [[ ${target_platform} =~ linux-* ]]; then
  echo "Nothing special for linux"
elif [[ ${target_platform} == osx-64 ]]; then
  CMAKE_EXTRA_ARGS+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
else
  echo "target_platform not known: ${target_platform}"
  exit 1
fi

# mkdir build-py${PY_VER}
# pushd build-py${PY_VER}

pushd build

cmake .. -LAH -G "Ninja"  \
  -DCMAKE_BUILD_TYPE="Release"  \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"  \
  -DCMAKE_SKIP_RPATH=ON  \
  -DCMAKE_AR="${AR}"  \
  -DCMAKE_LINKER="${LD}"  \
  -DCMAKE_NM="${NM}"  \
  -DCMAKE_BUILD_STATIC_LIBS=OFF  \
  -DBUILD_STATIC_LIBS=OFF  \
  -DBUILD_SHARED_LIBS=ON  \
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
ninja -v pyLIEF
if [[ ! $? ]]; then
  echo "Build failed with $?"
  exit 1
fi
ninja -v install
if [[ ! $? ]]; then
  echo "Install failed with $?"
  exit 1
fi
ext_suffix="$( ${PYTHON} -c 'from sysconfig import get_config_var as get; print(get("EXT_SUFFIX") or get("SO"))' )"
mv api/python/lief.so ${SP_DIR}/lief${ext_suffix}
if [[ ${target_platform} == osx-64 ]]; then
  ${INSTALL_NAME_TOOL:-install_name_tool} -id @rpath/_pylief${ext_suffix} ${SP_DIR}/lief${ext_suffix}
fi

${PYTHON} -c "import lief"

# conda run is broken. It does not remove the shell-script-added base-env PATH entries from the
# front of PATH, so when it adds the new env, if there was *another* env activated, then that is
# the one that gets replaced with the PREFIX env PATH entries. Software from the base-env gets
# run instead. This happens on all OSes and this test-code cannot be enabled until conda run is
# free of this problem.
# conda run -p ${PREFIX} --debug-wrapper-scripts which python
# conda run -p ${PREFIX} --debug-wrapper-scripts python -v --version 2>&1 | grep ${PY_VER}
# if [[ ! $? ]]; then
#   echo "conda run runs the wrong python"
#   exit 1
# fi
# conda run -p ${PREFIX} --debug-wrapper-scripts python -v -c "import lief" 2>&1 | grep "The specified module could not be found"
# if [[ ! $? ]]; then
#   echo "conda run ${PREFIX} --debug-wrapper-scripts python \"import lief\" runs the wrong python"
#   exit 1
# fi

if [[ -d "${PREFIX}"/share/LIEF/examples ]]; then
  rm -rf "${PREFIX}"/share/LIEF/examples/
fi
