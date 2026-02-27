# Script to build LAMMPS in IsambardAI (GH200)

git clone --single-branch --branch stable https://github.com/lammps/lammps.git lammps_src
cd lammps_src
git checkout stable_22Jul2025_update3

module load craype-network-ofi
module load PrgEnv-gnu 
module load gcc-native/13.2 
module load cray-mpich
module load cuda/12.6
module load craype-accel-nvidia90
module load craype-arm-grace
module load cray-python
module load cray-fftw

builddir=_build

if [ -d $builddir ]
then
   rm -r ${builddir}
fi

mkdir $builddir
cd $builddir
cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_Fortran_COMPILER=ftn \
    -D CMAKE_C_COMPILER=cc \
    -D CMAKE_CXX_COMPILER=CC \
    -D CMAKE_CXX_FLAGS="-DCUDA_PROXY -fPIC" \
    -D BUILD_MPI=yes \
    -D BUILD_OPENMP=no \
    -D CMAKE_INSTALL_PREFIX=/projects/u6cb/software/LAMMPS/22Jul2025 \
    -D LAMMPS_EXCEPTIONS=on \
    -D BUILD_SHARED_LIBS=on \
    -D PKG_KOKKOS=yes -D Kokkos_ARCH_HOPPER90=ON -D Kokkos_ENABLE_CUDA=yes -D FFT_KOKKOS=CUFFT \
    -D CUDPP_OPT=no -D CUDA_MPS_SUPPORT=yes -D CUDA_ENABLE_MULTIARCH=no \
    -D PKG_MOLECULE=yes \
    -D PKG_MANYBODY=yes \
    -D PKG_REPLICA=yes \
    -D PKG_ML-SNAP=yes \
    -D PKG_EXTRA-FIX=yes \
    -D PKG_MPIIO=yes \
    -D LAMMPS_SIZES=BIGBIG \
    ../cmake \
    | tee cmake_configure.log

make -j16 | tee build.log
make -j16 install | tee install.log
