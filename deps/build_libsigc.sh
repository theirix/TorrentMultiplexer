#!/bin/sh
set -e
BUILDROOT=`pwd`
NAME=libsigc
TARNAME=libsigc++-2.2.10
INSTALL_DIR=$BUILDROOT/$NAME-prefix
FRAMEWORK=$NAME.framework
MAJOR=2.0.0

trap "cd $BUILDROOT" EXIT

rm -rf $TARNAME $FRAMEWORK $INSTALL_DIR
tar xf $TARNAME.tar.bz2

cd $TARNAME
./configure --prefix=$INSTALL_DIR
make 
make install

echo Packaging framework
cd $BUILDROOT
mkdir -p $BUILDROOT/$FRAMEWORK/Versions/$MAJOR/Headers $BUILDROOT/$FRAMEWORK/Versions/$MAJOR/Resources 
cd $BUILDROOT/$FRAMEWORK
ln -s Versions/$MAJOR/Headers Headers
ln -s Versions/$MAJOR/Resources Resources
cp -R $INSTALL_DIR/include/sigc++-2.0/* $BUILDROOT/$FRAMEWORK/Headers/
cp -R $INSTALL_DIR/lib/sigc++-2.0/include/* $BUILDROOT/$FRAMEWORK/Headers/
cp -RH $INSTALL_DIR/lib/libsigc-2.0.0.dylib $BUILDROOT/$FRAMEWORK/Versions/$MAJOR/$NAME
ln -s Versions/$MAJOR/$NAME $NAME
cp $BUILDROOT/Info.$NAME.plist Resources/Info.plist

install_name_tool -id @executable_path/../Frameworks/$FRAMEWORK/$NAME $BUILDROOT/$FRAMEWORK/$NAME

rm -rf $TARNAME $INSTALL_DIR
