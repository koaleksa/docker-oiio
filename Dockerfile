FROM koaleksa/ocio:2.0.1

# yum installs
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install centos-release-scl && \
    yum -y install \
    gcc-c++ \
    devtoolset-7-gcc-c++ \
    make \
    automake \
    libtool \
    which \
    zlib-devel \
    boost-devel \
    libtiff-devel \
    libpng-devel \
    libjpeg-turbo-devel \
    giflib-devel \
    bzip2-devel \
    LibRaw-devel \
    libwebp-devel \
    freetype-devel \
    git

# install newish CMake
RUN mkdir -p /tmp/cmake && \
    pushd /tmp/cmake && \
    wget 'https://cmake.org/files/v3.20/cmake-3.20.1-linux-x86_64.sh' && \
    bash cmake-3.20.1-linux-x86_64.sh --prefix=/usr/local --exclude-subdir && \
    popd && \
    rm -rf /tmp/cmake

# OpenEXR
ARG OPENEXR_ROOT=/opt/openexr
ARG OPENEXR_VER=2.3.0
WORKDIR ${OPENEXR_ROOT}
RUN curl -O -L https://github.com/openexr/openexr/archive/v${OPENEXR_VER}.tar.gz && \
    tar -xvzf v${OPENEXR_VER}.tar.gz && \
    cd openexr-${OPENEXR_VER} && \
    # enable gcc 7
    source /opt/rh/devtoolset-7/enable && \
    # IlmBase
    cd IlmBase && \
    ./bootstrap && \
    ./configure && \
    make && \
    make install && \
    # OpenEXR
    cd ../OpenEXR && \
    ./bootstrap && \
    ./configure && \
    make && \
    make install

# OpenImageIO
ARG OPENIMAGEIO_ROOT=/opt/oiio
ARG OPENIMAGEIO_VER=Release-2.2.16.0
WORKDIR ${OPENIMAGEIO_ROOT}
RUN curl -O -L https://github.com/OpenImageIO/oiio/archive/${OPENIMAGEIO_VER}.tar.gz && \
    tar -xvzf ${OPENIMAGEIO_VER}.tar.gz && \
    cd oiio-${OPENIMAGEIO_VER} && \
    # enable gcc 7
    source /opt/rh/devtoolset-7/enable && \
    mkdir build && \
    cd build && \
    cmake -DOIIO_BUILD_TESTS=0 -DUSE_OPENGL=0 -DUSE_QT=0 -DUSE_PYTHON=0 -DUSE_FIELD3D=0 -DUSE_FFMPEG=0 -DUSE_OPENJPEG=0 -DUSE_OPENCV=0 -DUSE_OPENSSL=0 -DUSE_PTEX=0 -DUSE_NUKE=0 -DUSE_DICOM=0 ../ && \
    make && \
    make install

# cleanup
WORKDIR /
RUN rm -rf ${OPENEXR_ROOT} && \
    rm -rf ${OPENIMAGEIO_ROOT} && \
    yum erase -y epel-release centos-release-scl gcc-c++ devtoolset-7-gcc-c++ make cmake automake libtool which zlib-devel boost-devel libtiff-devel libpng-devel libjpeg-turbo-devel giflib-devel bzip2-devel LibRaw-devel libwebp-devel freetype-devel && \
    rm -rf /var/cache/yum && \
    hash -r
