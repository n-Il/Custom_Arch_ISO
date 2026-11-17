#!/bin/bash
tar -czf files.tar.gz files/
makepkg -s
rm -r src/
rm files.tar.gz
rm -r pkg/
