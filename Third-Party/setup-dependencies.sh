set -e

# DEPENDENCIES
#
# HOMEBREW
# brew install cmake meson ninja automake autoconf autoconf-archive libtool wget
#
# PYTHON
# python3 -m venv pyenv
# source pyenv/bin/activate
# pip install six pyparsing

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

cd $SCRIPTPATH

# PKG PATHS
OPUS_PKG="$SCRIPTPATH/opus/lib/pkgconfig"
PIXMAN_PKG="$SCRIPTPATH/pixman/lib/pkgconfig"
LIBJPEG_PKG="$SCRIPTPATH/libjpeg/lib/pkgconfig"
OPENSSL_PKG="$SCRIPTPATH/openssl/lib/pkgconfig"
GLIB_PKG="$SCRIPTPATH/glib/lib/pkgconfig"
LIBSLIRP_PKG="$SCRIPTPATH/libslirp/lib/pkgconfig"
SPICE_PROTO_PKG="$SCRIPTPATH/spice-protocol/share/pkgconfig"
SPICE_PKG="$SCRIPTPATH/spice/lib/pkgconfig"

export PKG_CONFIG_PATH="$OPUS_PKG:\
$PIXMAN_PKG:\
$LIBJPEG_PKG:\
$OPENSSL_PKG:\
$GLIB_PKG:\
$LIBSLIRP_PKG:\
$SPICE_PROTO_PKG:\
$SPICE_PKG"

# LIBPNG
if [ ! -d "pcre2" ]; then

    if [ ! -d "pcre2-src" ]; then
        git clone https://github.com/PhilipHazel/pcre2.git pcre2-src
    fi

    cd pcre2-src && mkdir build
    
    cd build && cmake .. \
         -DCMAKE_INSTALL_PREFIX="$SCRIPTPATH/pcre2" \
         -DCMAKE_BUILD_TYPE=Release \
         -DBUILD_SHARED_LIBS=OFF \
         -DPCRE2_BUILD_PCRE2_8=ON \
         -DPCRE2_BUILD_PCRE2_16=OFF \
         -DPCRE2_BUILD_PCRE2_32=OFF
    
    mkdir "$SCRIPTPATH/pcre2"
    
    make && make install && make clean && cd ../..
fi

rm -fr libpng-src

# GLIB
if [ ! -d "glib" ]; then

    if [ ! -d "glib-src" ]; then
        git clone https://gitlab.gnome.org/GNOME/glib.git glib-src
    fi

    cd glib-src
    
    meson setup build \
        --default-library=static \
        --prefix="$SCRIPTPATH/glib" \
        -Dglib_debug=disabled \
        -Dsystemtap=disabled \
        -Dlibmount=disabled \
        -Dc_args="-I$SCRIPTPATH/pcre2/include" \
        -Dcpp_args="-I$SCRIPTPATH/pcre2/include" \
        -Dcpp_link_args="-L$SCRIPTPATH/pcre2/lib -lpcre2-8"
    
    mkdir "$SCRIPTPATH/glib"
    
    ninja -C build && ninja -C build install && cd ..
fi

rm -fr glib-src

# OPENSSL
if [ ! -d "openssl" ]; then

    if [ ! -d "openssl-src" ]; then
        git clone https://github.com/openssl/openssl.git openssl-src
    fi

    cd openssl-src

    ./Configure \
      no-shared \
      --prefix=$SCRIPTPATH/openssl
    
    mkdir "$SCRIPTPATH/openssl"
    
    make && make install && make clean && cd ..
fi

rm -fr openssl-src

# ZLIB
if [ ! -d "zlib" ]; then

    if [ ! -d "zlib-src" ]; then
        git clone https://github.com/madler/zlib.git zlib-src
    fi
    
    cd zlib-src
    
    ./configure \
      --static \
      --prefix="$SCRIPTPATH/zlib"
    
    mkdir "$SCRIPTPATH/zlib"
    
    make && make install && make clean && cd ..
fi

rm -fr zlib-src

# LIBJPEG-TURBO
if [ ! -d "libjpeg" ]; then

    if [ ! -d "libjpeg-src" ]; then
        git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git libjpeg-src
    fi
    
    cd libjpeg-src && mkdir build
    
    cd build && cmake .. \
        -DCMAKE_INSTALL_PREFIX="$SCRIPTPATH/libjpeg" \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_SHARED=OFF \
        -DENABLE_STATIC=ON
    
    mkdir "$SCRIPTPATH/libjpeg"
    
    make && make install && make clean && cd ../..
fi

rm -fr libjpeg-src

# PIXMAN
if [ ! -d "pixman" ]; then

    if [ ! -d "pixman-src" ]; then
        git clone https://gitlab.freedesktop.org/pixman/pixman.git pixman-src
    fi
    
    cd pixman-src
    
    meson setup build \
        --prefix="$SCRIPTPATH/pixman" \
        --default-library=static
    
    mkdir "$SCRIPTPATH/pixman"
    
    ninja -C build && ninja -C build install && cd ..
fi

rm -fr pixman-src

# OPUS
if [ ! -d "opus" ]; then

    if [ ! -d "opus-src" ]; then
        git clone https://github.com/xiph/opus.git opus-src
    fi
    
    cd opus-src && ./autogen.sh
    
    ./configure --prefix="$SCRIPTPATH/opus" \
        --enable-static \
        --disable-shared

    mkdir "$SCRIPTPATH/opus"

    make -j$(sysctl -n hw.logicalcpu) && make install && cd ..
fi

rm -fr opus-src

# LIBSLIRP
if [ ! -d "libslirp" ]; then

    if [ ! -d "libslirp-src" ]; then
        git clone https://gitlab.freedesktop.org/slirp/libslirp.git libslirp-src
    fi

    cd libslirp-src
    
    meson setup build \
        --default-library=static \
        --prefix="$SCRIPTPATH/libslirp"
    
    mkdir "$SCRIPTPATH/libslirp"
    
    ninja -C build && ninja -C build install && cd ..
fi

rm -fr libslirp-src

# SPICE-PROTO
if [ ! -d "spice-protocol" ]; then

    if [ ! -d "spice-protocol-src" ]; then
        git clone https://gitlab.freedesktop.org/spice/spice-protocol.git spice-protocol-src
    fi

    cd spice-protocol-src
    
    meson setup build \
        --default-library=static \
        --prefix="$SCRIPTPATH/spice-protocol"
    
    mkdir "$SCRIPTPATH/spice-protocol"
    
    ninja -C build && ninja -C build install && cd ..
fi

rm -fr spice-protocol-src

# SPICE
if [ ! -d "spice" ]; then

    if [ ! -d "spice-src" ]; then
        git clone --recurse-submodules https://gitlab.freedesktop.org/spice/spice.git spice-src
    fi

    cd spice-src
    
    ./autogen.sh --prefix="$SCRIPTPATH/spice" \
        --enable-static \
        --disable-shared \
        --disable-tests \
        CFLAGS="-I$SCRIPTPATH/libjpeg/include" \
        LDFLAGS="-L$SCRIPTPATH/libjpeg/lib -ljpeg" \
        CPPFLAGS="-I$SCRIPTPATH/libjpeg/include"

    mkdir "$SCRIPTPATH/spice"

    PATH="$SCRIPTPATH/glib/bin:$PATH" \
    make -j$(sysctl -n hw.logicalcpu) && make install && cd ..
fi

rm -fr spice-src

# QEMU
if [ ! -d "QEMU" ]; then

    if [ ! -d "qemu-src" ]; then
        wget https://download.qemu.org/qemu-9.2.2.tar.xz -O qemu-src.tar.xz
        tar xvJf qemu-src.tar.xz && rm qemu-src.tar.xz
        mv qemu* qemu-src
    fi

    cd qemu-src
    
    ./configure --prefix="$SCRIPTPATH/QEMU" \
        --target-list=aarch64-softmmu,arm-softmmu,i386-softmmu,m68k-softmmu,ppc-softmmu,ppc64-softmmu,riscv32-softmmu,riscv64-softmmu,x86_64-softmmu \
        --enable-hvf \
        --enable-spice \
        --enable-coreaudio \
        --enable-cocoa \
        --enable-slirp \
        --disable-sdl \
        --disable-vnc \
        --disable-debug-info \
        --disable-strip \
        --extra-cflags="-I$SCRIPTPATH/spice/include \
                        -I$SCRIPTPATH/spice-protocol/include \
                        -I$SCRIPTPATH/pixman/include \
                        -I$SCRIPTPATH/opus/include \
                        -I$SCRIPTPATH/openssl/include \
                        -I$SCRIPTPATH/glib/include \
                        -I$SCRIPTPATH/libjpeg/include \
                        -I$SCRIPTPATH/libslirp/include" \
        --extra-ldflags="-L$SCRIPTPATH/spice/lib \
                         -L$SCRIPTPATH/pixman/lib \
                         -L$SCRIPTPATH/opus/lib \
                         -L$SCRIPTPATH/openssl/lib \
                         -L$SCRIPTPATH/glib/lib \
                         -L$SCRIPTPATH/libjpeg/lib \
                         -L$SCRIPTPATH/libslirp/lib \
                         -Bstatic -lglib-2.0 -lssl -lcrypto -lspice-server -lpixman-1 -lopus -ljpeg -lslirp \
                         -lc++ -lc++abi \
                         -Bdynamic -lc -lSystem"

    mkdir "$SCRIPTPATH/QEMU"

    make -j$(sysctl -n hw.logicalcpu) && make install && cd ..
fi

rm -fr qemu-src
