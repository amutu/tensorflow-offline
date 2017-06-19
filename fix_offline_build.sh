#!/bin/sh

install_dir="$(cd $(/usr/bin/dirname $0);pwd)"

tensorflow_dir=$1
third_package_dir=$2

cd ${tensorflow_dir} && patch -p0 < ${install_dir}/tensorflow-port/files/patch-WORKSPACE
cd ${tensorflow_dir} && patch -p0 < ${install_dir}/tensorflow-port/files/patch-tensorflow_workspace.bzl

sed -i.bk "s#bazel \([cf]\)#echo comment bazel \1#g" ${tensorflow_dir}/configure
sed -i.bk "s#tensorflow_third_party#${third_package_dir}#g" ${tensorflow_dir}/WORKSPACE
sed -i.bk "s#tensorflow_third_party#${third_package_dir}#g" ${tensorflow_dir}/tensorflow/workspace.bzl

echo "fix done, change to the tensorflow dir and follow the offical steps to build"
