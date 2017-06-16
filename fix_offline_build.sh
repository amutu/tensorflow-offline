#!/bin/sh

install_dir="$(cd $(/usr/bin/dirname $0);pwd)"

tensorflow_dir=$1
third_package_dir=$2

cp ${install_dir}/WORKSPACE ${tensorflow_dir}/
cp ${install_dir}/configure ${tensorflow_dir}/
cp ${install_dir}/workspace.bzl ${tensorflow_dir}/tensorflow/

sed -i.bk "s#tensorflow_third_party#${third_package_dir}#g" ${tensorflow_dir}/WORKSPACE
sed -i.bk "s#tensorflow_third_party#${third_package_dir}#g" ${tensorflow_dir}/tensorflow/workspace.bzl

echo "fix done, change to the tensorflow dir and follow the offical steps to build"
