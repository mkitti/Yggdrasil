using BinaryBuilder

# Collection of sources required to build Nettle
name = "dmg2img"
version = v"1.6.8"
sources = [
    GitSource("https://github.com/Lekensteyn/dmg2img.git", "a3e413489ccdd05431401357bf21690536425012"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/dmg2img*/

make -j${nproc} CFLAGS="-O2 -Wall -I${prefix}/include" LDFLAGS="-L${prefix}/lib -lssl"
make install DESTDIR=${prefix}
mv ${prefix}/usr/bin/* ${prefix}/bin/
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()
filter!(!Sys.isfreebsd, platforms)
filter!(!Sys.iswindows, platforms)

# The products that we will ensure are always built
products = [
    ExecutableProduct("dmg2img", :dmg2img)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("Zlib_jll"),
    # Future versions of bzip2 should allow a more relaxed compat because the
    # soname of the macOS library shouldn't change at every patch release.
    Dependency("Bzip2_jll", v"1.0.6"; compat="=1.0.6"),
    Dependency("OpenSSL_jll"; compat="1.1.10"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
