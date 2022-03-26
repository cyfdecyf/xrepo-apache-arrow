# Build Apache Arrow and PyArrow using Xrepo

This project shows how to build [Apache Arrow](https://arrow.apache.org/) and
[PyArrow](https://arrow.apache.org/docs/python/index.html) package using Xrepo
on Linux.

If you want to use C++11 ABI when using PyArrow, you have to compile both Arrow
and PyArrow by yourself.

[Xrepo](https://xrepo.xmake.io/) is a simple to use C++ package manager. It's
part of the [Xmake](https://xmake.io/) project which is a cross-platform build
utility based on Lua

Installing Xmake is simple and it takes only about 12MB disk space.

```
# Unix system
bash <(curl -fsSL https://xmake.io/shget.text)
# PowerShell
Invoke-Expression (Invoke-Webrequest 'https://xmake.io/psget.text' -UseBasicParsing).Content
```

For a simple install of arrow, just run the following command is enough:

```
xrepo install arrow
```

But to enable more Arrow features, you need more advanced usage of Xrepo, which 
is the purpose of this project.

## Building Arrow

To build Arrow static library with many features enabled, just run:

```
xrepo install pkg/arrow.lua
```

To change compiler used, pass `--toolchain` option:

```
xrepo install --toolchain=gcc-9 pkg/arrow.lua
xrepo install --toolchain=gcc-11 pkg/arrow.lua
```

To see a list of supported toolchains:

```
xmake show -l toolchains | sort
```

Edit [`pkg/common.lua`](./pkg/common.lua) to change Arrow configs.

## Building PyArrow package

Take a look at [`build.sh`](./build.sh) and change according to your need.

- Currently, only Arrow 7.0.0 is supported.
- You can easily select different compilers.

Requirements:

- Linux system with cmake, make, gcc and other build releated tools.
- Python 3 environment with `cython` and `numpy` installed.
  - The `build.sh` script has a `setup_python_env` function which sets up the minimal 
    python environment using `conda`
  - You can comment the call to `setup_python_env` to use your own python 
    environment.
  - Tested with `cython==0.29.28` and `numpy==1.21.5`. Other versions may also work.

After making necessary changes to `build.sh`, just run it:

```
./build.sh
```

If everything goes well, you can install the pyarrow wheel by running:

```
pip install apache-arrow-7.0.0/python/dist/pyarrow-7.0.0-cp37-cp37m-linux_x86_64.whl
```

### Details of the build process

The main usage of xrepo is:

```
xrepo install --toolchain=gcc-9 pkg/arrow-python.lua
```

This will download all the dependencies' source code and start building.

After installing python enabled C++ package, PyArrow wheel is built with:

```
arrow_includedir=$(XMAKE_COLORTERM=nocolor xrepo fetch ${toolchain} pkg/arrow-python.lua | awk -F \" '/packages.*include/ { print $2 }')
arrow_installdir=$(dirname $arrow_includedir)

export CMAKE_PREFIX_PATH=$arrow_installdir
export PYARROW_WITH_PARQUET=1
export PYARROW_WITH_DATASET=1
export PYARROW_WITH_PLASMA=1
python setup.py -- build_ext --build-type=release --bundle-arrow-cpp bdist_wheel
```

By setting `CMAKE_PREFIX_PATH`, `setup.py` is able to call cmake `find_package`
to find various Arrow C++ libraries.

For more details on building PyArrow, please refer to [PyArrow's doc](https://arrow.apache.org/docs/developers/python.html#building-on-linux-and-macos).

## Xrepo package config with Lua script

[`pkg/common.lua`](./pkg/common.lua) is a Lua script containing all package
configurations that's used. It sets package version and configs.

Here's the configs for arrow:

```lua
    arrow = {
        version = "7.0.0",
        configs = {
            mimalloc = true, jemalloc = false,
            engine = true, dataset = true, plasma = true, re2 = true, utf8proc = true,
            shared_dep = false,
            csv = true, json = false, parquet = true,
            brotli = true, bz2 = true, lz4 = true, zlib = true, zstd = true,
            -- python = true, shared = true
        },
    }
```

Arrow depends on lots of packages. Complexity arises when

- Some packages are used by multiple packages.
- Packages A requires a specific version of package B.

Using symbol `->` for dependency, here are a few dependencies we have:

- arrow `->` boost, thrift, bzip2, zlib
- thrift `->` -> boost, libevent, openssl
- boost `->` bzip2, zlib
- libevent `->` openssl

We can specify package version on command line:

```
xrepo install "arrow 7.0.0"
```

This will install arrow version 7.0.0. But as we are not specifying version for
dependent packages, Xrepo will use the latest version by default.

It's better to fix package versions to avoid new package breaking build.

- [`pkg/arrow.lua`](./pkg/arrow.lua) uses [`pkg/common.lua`](./pkg/common.lua)
  to accomplish this.
- [`pkg/arrow_python.lua`](./pkg/arrow-python.lua) is the same as above but
  enables python support.

Take a look at those two scripts to see how to fix all packages' versions and
configs.
