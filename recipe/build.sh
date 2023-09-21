#!/bin/bash
set -ex

mkdir build
cd build

# Remove dead stripping dylibs as the linker fails to realize that python symbols
# are missing in liblldb.dylib
export LDFLAGS=$(echo $LDFLAGS | sed 's/-Wl,-dead_strip_dylibs//g')

if [[ "$target_platform" == osx* ]]; then
  LLDB_USE_SYSTEM_DEBUGSERVER=ON
else
  LLDB_USE_SYSTEM_DEBUGSERVER=OFF
fi

cmake \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DLLDB_ENABLE_PYTHON=ON \
  -DLLDB_ENABLE_LIBEDIT=ON \
  -DLLDB_ENABLE_CURSES=ON \
  -DLLDB_ENABLE_LZMA=ON \
  -DLLDB_ENABLE_LIBXML2=ON \
  -DLLDB_ENABLE_TESTS=OFF \
  -DLLDB_USE_SYSTEM_DEBUGSERVER=$LLDB_USE_SYSTEM_DEBUGSERVER \
  -DCURSES_LIBRARY=$PREFIX/lib/libncurses$SHLIB_EXT \
  -DHAVE_LIBCOMPRESSION=NO \
  ../lldb

ninja -j${CPU_COUNT} --verbose
ninja install
