#!/bin/bash

set -e

arrow_version=7.0.0

# Uncomment this to compile with different compiler.
# Without defining toolchain, system default is used.
# Note: gcc-4.8 is not supported.
#toolchain="--toolchain=gcc-9"
#toolchain="--toolchain=gcc-11"
#toolchain="--toolchain=clang-13"

# You can use your own python environment, as long as cython and numpy is
# installed and version satisfies pyarrow's requirements.
setup_python_env() {
    conda create -n pyarrow python=3.7
    conda activate pyarrow
    pip install cython numpy
}

install_arrow_python() {
    # -v for verbose, -D for diagnosis message.
    xrepo install -vD ${toolchain} pkg/arrow-python.lua
    arrow_includedir=$(XMAKE_COLORTERM=nocolor xrepo fetch ${toolchain} pkg/arrow-python.lua | awk -F \" '/packages.*include/ { print $2 }')
    arrow_installdir=$(dirname $arrow_includedir)
    echo "arrow install dir: $arrow_installdir"
}

build_pyarrow_wheel() {
    # Look for arrow source tarball in xmake's cache.
    arrow_tarball=$(ls ~/.xmake/cache/packages/*/a/arrow/${arrow_version}/apache-arrow-${arrow_version}.tar.gz)
    echo $arrow_tarball

    tar xf $arrow_tarball

    pushd apache-arrow-${arrow_version}/python

    export CMAKE_PREFIX_PATH=$arrow_installdir
    export PYARROW_WITH_PARQUET=1
    export PYARROW_WITH_DATASET=1
    export PYARROW_WITH_PLASMA=1
    python setup.py -- build_ext --build-type=release --bundle-arrow-cpp bdist_wheel

    popd

    wheel=$(ls apache-arrow-${arrow_version}/python/dist/*.whl)
    echo "pyarrow wheel built, install with"
    echo "    pip install $wheel"
}

setup_python_env
install_arrow_python
build_pyarrow_wheel

