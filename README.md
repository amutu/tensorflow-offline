# tensorflow_offline

## usage:

* download src
> tensorflow src [tensorflow](https://github.com/tensorflow/tensorflow/releases) and offline third party package [tensorflow_third_party](https://github.com/amutu/tensorflow_third_party) and extract. The extracted directories are $tf and $tp, and must be absolute path.

* fix the build,do as
> git clone https://github.com/amutu/tensorflow_offline.git  
> cd tensorflow_offline  
> ./fix_offline_build.sh $tf $tp  

* do the build
> cd $tf && ./configure  
> bazel --config=opt //tensorflow/tools/pip_package:build_pip_package --verbose_failures  
> bazel-bin/tensorflow/tools/pip_package/build_pip_package  

* note:
test tensorflow-1.1.0 on FreeBSD without CUDA,openCL,XLA support.Linux or other Unix should work too.
