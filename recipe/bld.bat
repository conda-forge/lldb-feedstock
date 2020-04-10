mkdir build
cd build

echo %PATH%
set PY_VER_NO_DOT=%PY_VER:.=%

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DCLANG_INCLUDE_TESTS=OFF ^
    -DCLANG_INCLUDE_DOCS=OFF ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_DOCS=OFF ^
    -DLLVM_TARGETS_TO_BUILD=X86 ^
    -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON ^
    -DLLDB_ENABLE_PYTHON=ON ^
    -DLLDB_PYTHON_RELATIVE_PATH=../Lib/site-packages ^
    -DPYTHON_HOME=%PREFIX% ^
    -DLLDB_EMBED_PYTHON_HOME=OFF ^
    -DPYTHON_LIBRARIES=%PREFIX%/libs/python%PY_VER_NO_DOT%.lib ^
    -DPYTHON_INCLUDE_DIRS=%PREFIX%/include ^
    -DPYTHON_EXECUTABLE=%PREFIX%/python.exe ^
    -DSWIG_EXECUTABLE=%LIBRARY_BIN%/swig.exe ^
    %SRC_DIR%

if errorlevel 1 exit 1

ninja -j%CPU_COUNT% --verbose
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
