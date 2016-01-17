#!/bin/bash

gnatmake io_put_example.adb -aI../src
rm *.ali *.o
