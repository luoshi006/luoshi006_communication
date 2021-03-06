#!/bin/bash

## Bash script for setting up a PX4 development environment for Pixhawk/NuttX targets on Ubuntu LTS (16.04).
## It can be used for installing simulators and the NuttX toolchain.
##
## Installs:
## - Common dependencies and tools for all targets (including: Ninja build system, Qt Creator, pyulog)
## - FastRTPS and FastCDR
## - jMAVSim simulator
## - Gazebo8 simulator
## - NuttX toolchain (i.e. gcc compiler)
## - PX4/Firmware source (to ~/src/Firmware/)

# Ubuntu Config
sudo usermod -a -G dialout $USER
sudo apt-get remove modemmanager -y


# Ninja build system
ninja_dir=$HOME/ninja
echo "Installing Ninja to: $ninja_dir."
if [ -d "$ninja_dir" ]
then
    echo " Ninja already installed."
else
    pushd .
    mkdir -p $ninja_dir
    cd $ninja_dir
    wget https://github.com/martine/ninja/releases/download/v1.6.0/ninja-linux.zip
    unzip ninja-linux.zip
    rm ninja-linux.zip
    exportline="export PATH=$ninja_dir:\$PATH"
    if grep -Fxq "$exportline" ~/.profile; then echo " Ninja already in path" ; else echo $exportline >> ~/.profile; fi
    . ~/.profile
    popd
fi


# Common Dependencies
echo "Installing common dependencies"
sudo add-apt-repository ppa:george-edison55/cmake-3.x -y
sudo apt-get update
sudo apt-get install python-argparse git-core wget zip python-empy qtcreator cmake build-essential genromfs -y
# required python packages
sudo apt-get install python-dev -y
sudo apt-get install python-pip
sudo -H pip install pandas jinja2
pip install pyserial
# optional python tools
pip install pyulog


# Install FastRTPS 1.5.0 and FastCDR-1.0.7
#fastrtps_dir=$HOME/eProsima_FastRTPS-1.5.0-Linux
#echo "Installing FastRTPS to: $fastrtps_dir"
#if [ -d "$fastrtps_dir" ]
#then
#    echo " FastRTPS already installed."
#else
#    pushd .
#    cd ~
#    wget http://www.eprosima.com/index.php/component/ars/repository/eprosima-fast-rtps/eprosima-fast-rtps-1-5-0/eprosima_fastrtps-1-5-0-linux-tar-gz
#    mv eprosima_fastrtps-1-5-0-linux-tar-gz eprosima_fastrtps-1-5-0-linux.tar.gz
#    tar -xzf eprosima_fastrtps-1-5-0-linux.tar.gz eProsima_FastRTPS-1.5.0-Linux/
#    tar -xzf eprosima_fastrtps-1-5-0-linux.tar.gz requiredcomponents
#    tar -xzf requiredcomponents/eProsima_FastCDR-1.0.7-Linux.tar.gz
#    cd eProsima_FastCDR-1.0.7-Linux; ./configure --libdir=/usr/lib; make; sudo make install
#    cd ..
#    cd eProsima_FastRTPS-1.5.0-Linux; ./configure --libdir=/usr/lib; make; sudo make install
#    popd
#fi


# jMAVSim simulator
#sudo apt-get install ant openjdk-8-jdk openjdk-8-jre -y

# Gazebo simulator
#sudo apt-get install protobuf-compiler libeigen3-dev libopencv-dev -y
#sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
## Setup keys
#wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
## Update the debian database:
#sudo apt-get update
## Install Gazebo8
#sudo apt-get install gazebo8 -y
## For developers (who work on top of Gazebo) one extra package
#sudo apt-get install libgazebo8-dev


# NuttX
sudo apt-get install python-serial openocd \
    flex bison libncurses5-dev autoconf texinfo \
    libftdi-dev libtool zlib1g-dev -y

# Clean up old GCC
sudo apt-get remove gcc-arm-* binutils-arm-none-eabi
sudo add-apt-repository --remove ppa:team-gcc-arm-embedded/ppa

pushd .
cd ~
#wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q3-update/+download/gcc-arm-none-eabi-4_8-2014q3-20140805-linux.tar.bz2
tar -jxf gcc-arm-none-eabi-4_8-2014q3-20140805-linux.tar.bz2
exportline="export PATH=$HOME/gcc-arm-none-eabi-4_8-2014q3/bin:\$PATH"
if grep -Fxq "$exportline" ~/.bash_profile; then echo nothing to do ; else echo $exportline >> ~/.profile; fi
popd

sudo dpkg --add-architecture i386
sudo apt-get update

sudo apt-get install libc6:i386 libgcc1:i386 libstdc++5:i386 libstdc++6:i386
sudo apt-get install gcc-4.8-base:i386 


# Clone PX4/Firmware
clone_dir=~/src
echo "Cloning PX4 to: $clone_dir."
if [ -d "$clone_dir" ]
then
    echo " Firmware already cloned."
else
    mkdir -p $clone_dir
    cd $clone_dir
    git clone https://github.com/PX4/Firmware.git
    cd Firmware
fi
cd $clone_dir/Firmware
    

#Reboot the computer (required before building)
echo RESTART YOUR COMPUTER to complete installation of PX4 development toolchain
