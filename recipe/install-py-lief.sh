#!/bin/bash

set -xeuo pipefail

CMAKE_ARGS="${CMAKE_ARGS} \
  -DBUILD_STATIC_LIBS=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_SKIP_RPATH=ON \
  -DLIEF_EXAMPLES=OFF \
  -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON \
  -DLIEF_PY_LIEF_EXT=ON \
  -DLIEF_PY_LIEF_EXT_SHARED=ON \
  -DLIEF_PYTHON_API=ON \
"

pushd api/python

mv -n config-default.toml config-default.toml.bak
while read -r line; do
  printf '%s\n' "${line}"
  case ${line} in ( '[lief.build]' )
    cat << EOF
lief-install-dir = "${PREFIX}"
extra-cmake-opt = [
$(printf '"%s",\n' ${CMAKE_ARGS})
]
EOF
  ;; esac
done < config-default.toml.bak > config-default.toml

EXT_SUFFIX="$( ${PYTHON} -c 'from sysconfig import get_config_var as get; print(get("EXT_SUFFIX") or get("SO"))' )"
export EXT_SUFFIX

pip install --no-deps --no-build-isolation --ignore-installed --no-index -vv .

rm -rf "${PREFIX}"/share/LIEF/examples/

popd
