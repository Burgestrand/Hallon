#!/bin/bash
gcc -c ../appkey.c
gcc -framework libspotify appkey.o single-release.c -o a.out && ./a.out