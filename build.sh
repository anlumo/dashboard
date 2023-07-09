#!/bin/sh

flutterpi_tool build --arch=arm64 --cpu=pi3 --release
# cd build
# scp -r flutter_assets dashboard@10.20.32.91:
