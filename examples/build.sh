#!/bin/bash

gnatmake io_put_example.adb -aI../src -g
rm *.ali *.o

gnatmake io_coprocess_example.adb -aI../src -g
rm *.ali *.o
