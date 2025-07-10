#!/bin/bash

root_dir=$(dirname "$(readlink -f "$0")")
git submodule update --init --recursive

# build UCX
cd ${root_dir}/3rdParty/ucx
./autogen.sh && ./autogen.sh
mkdir -p build && cd build
../contrib/configure-opt --prefix=${root_dir}/apps/ucx \
     --with-rocm=/opt/rocm \
     --without-knem \
     --without-cuda \
     --without-java \
     --enable-mt
make -j $(nproc)
make install

# build UCC
cd ${root_dir}/3rdParty/ucc
./autogen.sh && ./autogen.sh
mkdir -p build && cd build
../configure --prefix=${root_dir}/apps/ucc \
      --with-rocm=/opt/rocm \
      --with-ucx=${root_dir}/apps/ucx
make -j $(nproc)
make install

# build OpenMPI
cd ${root_dir}/3rdParty/openmpi
./autogen.pl
mkdir -p build && cd build
../configure --prefix=${root_dir}/apps/openmpi \
     --with-rocm=/opt/rocm \
     --with-ucx=${root_dir}/apps/ucx \
     --with-ucc=${root_dir}/apps/ucc  \
     --enable-mca-no-build=btl-uct
make -j $(nproc)
make install

# build HEFFTE
cd ${root_dir}/3rdParty/heffte
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${root_dir}/apps/heffte \
     -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang \
     -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ \
     -DCMAKE_HIP_COMPILER=/opt/rocm/bin/amdclang++ \
     -DCMAKE_BUILD_TYPE=Release \
     -DBUILD_SHARED_LIBS=ON     \
     -DMPI_ROOT=${root_dir}/apps/openmpi \
     -DHeffte_ENABLE_ROCM=ON \
     -DCMAKE_HIP_ARCHITECTURES=gfx942 \
     -DCMAKE_HIP_FLAGS=--offload-arch=gfx942 \
     -DCMAKE_CXX_FLAGS="-O3 --offload-arch=gfx942" \
     ..
make -j $(nproc)
make install   

# build GROMACS
cd ${root_dir}
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${root_dir}/apps/gromacs \
      -DCMAKE_PREFIX_PATH='/opt/rocm' \
      -DCMAKE_BUILD_TYPE=Release \
      -DROCM_PATH='/opt/rocm' \
      -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang \
      -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ \
      -DCMAKE_HIP_COMPILER=/opt/rocm/bin/amdclang++ \
      -DGMX_GPU=HIP \
      -DGMX_HIP_TARGET_ARCH=gfx942 \
      -DGMX_GPU_NB_DISABLE_CLUSTER_PAIR_SPLIT=ON \
      -DGMX_GPU_FFT_LIBRARY=rocFFT \
      -DREGRESSIONTEST_DOWNLOAD=ON \
      -DGMX_MPI=ON \
      -DMPI_ROOT=${root_dir}/apps/openmpi \
      -DGMX_OPENMP=ON \
      -DGMX_FFT_LIBRARY=fftw3 \
      -DGMX_BUILD_OWN_FFTW=ON \
      -DGMX_USE_HEFFTE=ON \
      -DHeffte_ROOT=${root_dir}/apps/heffte ..
make -j $(nproc)
make install   
