#!/bin/sh
set -e
BUILDROOT=`pwd`
NAME=libtorrent
TARNAME=$NAME-0.12.9
INSTALL_DIR=$BUILDROOT/$NAME-prefix
FRAMEWORK=$NAME.framework
MAJOR=14

trap "cd $BUILDROOT" EXIT

rm -rf $TARNAME $FRAMEWORK $INSTALL_DIR
tar xf $TARNAME.tar.gz

cd $TARNAME
./configure --prefix=$INSTALL_DIR --disable-openssl STUFF_CFLAGS="-I$BUILDROOT/libsigc.framework/Headers" STUFF_LIBS="-F$BUILDROOT -framework libsigc"
#./configure --prefix=$INSTALL_DIR STUFF_CFLAGS="-I$BUILDROOT/libsigc.framework/Headers" STUFF_LIBS="-L$BUILDROOT -framework libsigc"
#./configure --prefix=$INSTALL_DIR STUFF_LIBS="-L/projects/TorrentMultiplexer/deps/libsigcxx-prefix/lib" STUFF_CFLAGS="-I/projects/TorrentMultiplexer/deps/libsigcxx-prefix/include -I/projects/TorrentMultiplexer/deps/libsigcxx-prefix/include/sigc++-2.0 -I/projects/TorrentMultiplexer/deps/libsigcxx-prefix/lib/sigc++-2.0/include/"
make 
make install

cd $BUILDROOT
mkdir -p $BUILDROOT/$FRAMEWORK/Versions/$MAJOR/Headers $BUILDROOT/$FRAMEWORK/Versions/$MAJOR/Resources 
cd $BUILDROOT/$FRAMEWORK
ln -s Versions/$MAJOR/Headers Headers
ln -s Versions/$MAJOR/Resources Resources
cp -R $INSTALL_DIR/include/* $BUILDROOT/$FRAMEWORK/Headers/
cp -RH $INSTALL_DIR/lib/libtorrent.14.dylib $BUILDROOT/$FRAMEWORK/Versions/$MAJOR/libtorrent
ln -s Versions/$MAJOR/$NAME $NAME
cp $BUILDROOT/Info.$NAME.plist Resources/Info.plist

install_name_tool -id @executable_path/../Frameworks/$FRAMEWORK/$NAME $BUILDROOT/$FRAMEWORK/$NAME

rm -rf $INSTALL_DIR
