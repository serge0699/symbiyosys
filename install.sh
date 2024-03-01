#------------------------------------------------------------------
# Variables
#------------------------------------------------------------------

print_log() {
    echo "*--------------------------------------------------------"
    echo "* $1"
    echo "*--------------------------------------------------------"
}


#------------------------------------------------------------------
# Variables
#------------------------------------------------------------------

# Project directory
PRJ_DIR=$(pwd)

# Dependencies directory
DEP_DIR=$PRJ_DIR/dependencies

# Force build flag
FORCE=false


#------------------------------------------------------------------
# Check input arguments
#------------------------------------------------------------------

while getopts :hf opt; do
    case $opt in 
        h) echo "Script usage: install.sh [-f]"
           echo "\n-f (optional) | Force installation of all components" ; exit ;;
        f) FORCE=true ;;
       \?) echo "Unknown option -$OPTARG"; exit 1;;
    esac
done

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

print_log "Installing tools"

# Quietly update submodules
git submodule update --recursive --init

# Install Yosys, Yosys-SMTBMC and ABC
if [ -z "$(which yosys)" ] || $FORCE; then
    cd $DEP_DIR/yosys
    make -j$(nproc)
    sudo make install
else
    echo "Yosys, Yosys-SMTBMC and Yosys-ABC are already installed"
    echo "You can use -f flag to force installation anyway"
fi

# Install Sby
if [ -z "$(which sby)" ] || $FORCE; then
    cd $DEP_DIR/sby
    sudo make install
else
    echo "SymbiYosys is already installed"
    echo "You can use -f flag to force installation anyway"
fi

# Install Boolector
if [ -z "$(which boolector)" ] || $FORCE; then
    cd $DEP_DIR/boolector
    ./contrib/setup-btor2tools.sh
    ./contrib/setup-lingeling.sh
    ./configure.sh
    make -C build -j$(nproc)
    sudo cp build/bin/{boolector,btor*} /usr/local/bin/
    sudo cp deps/btor2tools/bin/btorsim /usr/local/bin/
else
    echo "Boolector is already installed"
    echo "You can use -f flag to force installation anyway"
fi

# Echo finish
print_log "Finished"
