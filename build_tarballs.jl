# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

# Collection of sources required to build DSFMTBuilder
sources = [
    "http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/SFMT/dSFMT-src-2.2.3.tar.gz" =>
    "82344874522f363bf93c960044b0a6b87b651c9565b6312cf8719bb8e4c26a0e",

    # dSFMT patches to create a shared library
    "patches",
]

# Bash recipe for building across all platforms
script = raw"""
cd dSFMT-src-2.2.3

# Apply all our patches
for f in $WORKSPACE/srcdir/*.patch; do
    patch -p1 < ${f}
done

DSFMT_CFLAGS="-DNDEBUG -DDSFMT_MEXP=19937 -fPIC -DDSFMT_DO_NOT_USE_OLD_NAMES  -O3 -finline-functions -fomit-frame-pointer -fno-strict-aliasing --param max-inline-insns-single=1800 -Wmissing-prototypes -Wall  -std=c99 -shared"

if [[ $target == x86_64-*  ]]; then
DSFMT_CFLAGS="$DSFMT_CFLAGS -msse2 -DHAVE_SSE2"
fi

mkdir -p $prefix/lib
$CC $DSFMT_CFLAGS dSFMT.c -o $prefix/lib/libdSFMT.$dlext

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    BinaryProvider.Linux(:i686, :glibc, :blank_abi),
    BinaryProvider.Linux(:x86_64, :glibc, :blank_abi),
    BinaryProvider.Windows(:x86_64, :blank_libc, :blank_abi),
    BinaryProvider.Windows(:i686, :blank_libc, :blank_abi),
    BinaryProvider.MacOS(:x86_64, :blank_libc, :blank_abi),
    BinaryProvider.Linux(:aarch64, :glibc, :blank_abi),
    BinaryProvider.Linux(:armv7l, :glibc, :eabihf),
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libdSFMT", :libdSFMT)
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "DSFMTBuilder", sources, script, platforms, products, dependencies)
