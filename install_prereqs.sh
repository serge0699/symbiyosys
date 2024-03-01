#------------------------------------------------------------------
# Variables
#------------------------------------------------------------------

print_log() {
    echo "*--------------------------------------------------------"
    echo "* $1"
    echo "*--------------------------------------------------------"
}

#------------------------------------------------------------------
# Installation
#------------------------------------------------------------------

print_log "Installing prerequisites"

# Install prerequisites

sudo kill -9 $(cat /var/run/yum.pid 2>/dev/null)

sudo yum group install -y "Development Tools"

sudo yum install -y centos-release-scl

sudo yum install -y clang readline-devel tcl-devel libffi-devel \
                    graphviz xdotool zlib-devel gtkwave llvm-toolset-7 \
                    gperf glibc-static libstdc++-static gmp-devel python3

sudo python3 -m pip install click dataclasses pyyaml

source scl_source enable llvm-toolset-7

sudo yum remove cmake -y
wget https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz
tar -zxvf cmake-3.6.2.tar.gz
cd cmake-3.6.2
sudo ./bootstrap --prefix=/usr/local
sudo make
sudo make install
