#!/bin/bash

pushd build

ninja -j${CPU_COUNT} -v && ninja -v install

if [[ -d "${PREFIX}"/share/LIEF/examples ]]; then
  rm -rf "${PREFIX}"/share/LIEF/examples/
fi

popd
