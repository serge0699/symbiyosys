#------------------------------------------------------------------
# Info
#------------------------------------------------------------------

# Tested on Ubuntu 20.04.6 LTS


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
        h) echo "Script usage: install_ubuntu.sh [-f]"
           echo "\n-f (optional) | Force installation of all components" ; exit ;;
        f) FORCE=true ;;
       \?) echo "Unknown option -$OPTARG"; exit 1;;
    esac
done

#------------------------------------------------------------------
# Installation
#------------------------------------------------------------------

# Quietly update submodules
git submodule update --recursive --init

print_log "Installing prerequisites"

# Install prerequisites
sudo apt-get install build-essential clang bison flex \
                     libreadline-dev gawk tcl-dev libffi-dev git \
                     graphviz xdot pkg-config python3 zlib1g-dev \
                     gtkwave

python3 -m pip install click

print_log "Installing tools"

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

# Install Yices 2
if [ -z "$(which yices)" ] || $FORCE; then
    cd $DEP_DIR/yices2
    autoconf
    ./configure
    make -j$(nproc)
    sudo make install
else
    echo "Yices 2 is already installed"
    echo "You can use -f flag to force installation anyway"
fi

# Echo finish
print_log "Finished"
