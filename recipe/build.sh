#!/bin/bash
set -ex

mkdir -p build
pushd build

# Remove dead stripping dylibs as the linker fails to realize that python symbols
# are missing in liblldb.dylib
export LDFLAGS=$(echo $LDFLAGS | sed 's/-Wl,-dead_strip_dylibs//g')

if [[ "$target_platform" == osx* ]]; then
  LLDB_USE_SYSTEM_DEBUGSERVER=ON
else
  LLDB_USE_SYSTEM_DEBUGSERVER=OFF
fi

if [[ "${target_platform}" != "${build_platform}" ]]; then
  NATIVE_FLAGS="-DCMAKE_C_COMPILER=$CC_FOR_BUILD;-DCMAKE_CXX_COMPILER=$CXX_FOR_BUILD;-DCMAKE_C_FLAGS=-O2;-DCMAKE_CXX_FLAGS=-O2"
  NATIVE_FLAGS="${NATIVE_FLAGS};-DCMAKE_EXE_LINKER_FLAGS=;-DCMAKE_MODULE_LINKER_FLAGS=;-DCMAKE_SHARED_LINKER_FLAGS="
  NATIVE_FLAGS="${NATIVE_FLAGS};-DCMAKE_STATIC_LINKER_FLAGS=;-DCMAKE_PREFIX_PATH=$BUILD_PREFIX"
  CMAKE_ARGS="${CMAKE_ARGS} -DCROSS_TOOLCHAIN_FLAGS_NATIVE=${NATIVE_FLAGS}"

  SP_PATH=${SP_DIR//$PREFIX}
  SP_PATH=${SP_PATH:1}
  export CMAKE_ARGS="${CMAKE_ARGS} -DLLVM_TABLEGEN=$BUILD_PREFIX/bin/llvm-tblgen -DLLDB_PYTHON_RELATIVE_PATH=${SP_PATH} -DLLDB_PYTHON_EXE_RELATIVE_PATH=bin/python -DLLDB_PYTHON_EXT_SUFFIX=$(python ../lldb/bindings/python/get-python-config.py LLDB_PYTHON_EXT_SUFFIX) -DNATIVE_LLVM_DIR=$BUILD_PREFIX/lib/cmake/llvm -DNATIVE_Clang_DIR=$BUILD_PREFIX/lib/cmake/clang"
fi

cmake ${CMAKE_ARGS} \
  -G Ninja \
  -DLLDB_ENABLE_PYTHON=ON \
  -DLLDB_ENABLE_LIBEDIT=ON \
  -DLLDB_ENABLE_CURSES=ON \
  -DLLDB_ENABLE_LZMA=ON \
  -DLLDB_ENABLE_LIBXML2=ON \
  -DLLDB_ENABLE_TESTS=OFF \
  -DLLDB_USE_SYSTEM_DEBUGSERVER=$LLDB_USE_SYSTEM_DEBUGSERVER \
  -DCURSES_LIBRARY=$PREFIX/lib/libncurses$SHLIB_EXT \
  -DPython3_ROOT=$PREFIX \
  -DPython3_EXECUTABLE=$PREFIX/bin/python \
  -DHAVE_LIBCOMPRESSION=NO \
  ../lldb

ninja -j${CPU_COUNT}
ninja install
