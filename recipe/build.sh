mkdir build
cd build

export CC=clang
export CXX=clang++

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLDB_CODESIGN_IDENTITY="" \
  ..

make -j${CPU_COUNT}
make install
