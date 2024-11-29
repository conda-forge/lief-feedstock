#!/bin/bash

set -xeu

ninja -C build -v -j${CPU_COUNT}

ninja -C build -v install

rm -rf "${PREFIX}"/share/LIEF/examples/
