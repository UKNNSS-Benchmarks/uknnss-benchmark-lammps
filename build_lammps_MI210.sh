#!/bin/bash

set -xe

module purge

# The build instructions have been verified for the following git sha.
# LAMMPS version - 29th July 2024
LAMMPS_COMMIT=abfdbec

HOME_BASE=$(pwd)
LAMMPS_SRC="${HOME_BASE}/lammps_src"
LAMMPS_BUILD_DIR="build_MI210"
INSTALL_PREFIX="${HOME_BASE}/install_MI210"
BUILD_THREADS=16

# Clone just the stable branch of LAMMPS if not already cloned.
if [ ! -d ${LAMMPS_SRC} ]; then
    git clone --single-branch --branch stable https://github.com/lammps/lammps.git ${LAMMPS_SRC}
fi

# Enter the lammps directory.
cd ${LAMMPS_SRC}

# The build instructions have been verified for the following git sha.
# LAMMPS version - 23 June 2022
git checkout ${LAMMPS_COMMIT}

# Create the build dir .
if [ ! -d ${LAMMPS_BUILD_DIR} ]; then
    mkdir ${LAMMPS_BUILD_DIR}
fi
cd ${LAMMPS_BUILD_DIR}
rm -rf *

# Help CMake find rocthrust
export CMAKE_PREFIX_PATH=/opt/rocm-7.0.2/lib/cmake/

# CMake build statement
# LAMMPS can either use GPU or Kokkos -- we use Kokkos here.
cmake \
  -D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D BUILD_MPI=yes \
  -D PKG_SNAP=yes \
  -D PKG_GPU=no \
  -D PKG_KOKKOS=yes \
  -D PKG_ML-SNAP=ON \
  -D CMAKE_CXX_COMPILER=hipcc \
  -D Kokkos_ENABLE_HIP=yes \
  -D Kokkos_ARCH_AMD_GFX90A=yes \
  ../cmake

# make && make install
make -j${BUILD_THREADS}
make install -j${BUILD_THREADS}
