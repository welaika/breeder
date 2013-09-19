SHELL = /bin/bash

PREFIX?=/usr/local

install:
	mkdir -p ${PREFIX}/{lib,bin}
	cp ./breeder.sh ${PREFIX}/bin/breeder
	cp -r ./breeder ${PREFIX}/lib/
	@echo Breeder installer. Try to type \'which breeder\'

uninstall:
	rm -rf ${PREFIX}/bin/breeder ${PREFIX}/lib/breeder
	@echo Breeder uninstalled
