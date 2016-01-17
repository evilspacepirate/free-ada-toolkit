#!/bin/bash

gnatmake io_example.adb -aI../src
rm *.ali *.o
