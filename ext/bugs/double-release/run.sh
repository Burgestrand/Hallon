#!/bin/bash
gcc -c ../appkey.c
gcc -framework libspotify appkey.o double-release.c -o a.out && ./a.out