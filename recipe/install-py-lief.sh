#!/bin/bash

set -xeuo pipefail

CMAKE_ARGS="${CMAKE_ARGS} \
  -DBUILD_STATIC_LIBS=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_SKIP_RPATH=ON \
  -DLIEF_EXAMPLES=OFF \
  -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON \
  -DLIEF_PYTHON_API=ON \
  -DLIEF_INSTALL_PYTHON=ON  \
  -DLIEF_EXTERNAL_PYBIND11=ON \
"

rm build/CMakeCache.txt

cmake "${CMAKE_ARGS}" -LAH -G "Ninja" -B build  \
  -DPYTHON_EXECUTABLE="${PYTHON}"  \
  -DPYTHON_INCLUDE_DIR:PATH=$(${PYTHON} -c 'from sysconfig import get_paths; print(get_paths()["include"])')  \
  -DPYTHON_LIBRARIES="${PREFIX}"/lib/libpython${PY_VER}.dylib  \
  -DPYTHON_LIBRARY="${PREFIX}"/lib/libpython${PY_VER}.dylib  \
  -DPYTHON_EXECUTABLE="${PREFIX}"/bin/python  \
  -DPYTHON_VERSION=${PY_VER}

ninja -C build -v pyLIEF -j${CPU_COUNT}
ninja -C build -v install -j${CPU_COUNT}

ext_suffix="$( ${PYTHON} -c 'from sysconfig import get_config_var as get; print(get("EXT_SUFFIX") or get("SO"))' )"
mv api/python/lief.so ${SP_DIR}/lief${ext_suffix}
if [[ ${target_platform} == osx-* ]]; then
  ${INSTALL_NAME_TOOL:-install_name_tool} -id @rpath/_pylief${ext_suffix} ${SP_DIR}/lief${ext_suffix}
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  ${PYTHON} -c "import lief"
fi

rm -rf "${PREFIX}"/share/LIEF/examples/
