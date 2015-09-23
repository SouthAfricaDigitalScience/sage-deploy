#/bin/bash -e
module load ci
module add gcc/4.8.4
echo ""
cd $WORKSPACE/$NAME-$VERSION
make check

echo $?

make install # DESTDIR=$SOFT_DIR
DIRS=`ls $SOFT_DIR`
echo "DIRS to include in the tarball are $DIRS"
mkdir -p $REPO_DIR
rm -rf $REPO_DIR/*
tar -cvzf $REPO_DIR/build.tar.gz -C $SOFT_DIR $DIRS

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       SAGE_VERSION       $VERSION
setenv       SAGE_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(SAGE_DIR)/lib

MODULE_FILE
) > modules/$VERSION

mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME
