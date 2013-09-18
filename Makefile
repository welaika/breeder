SHELL = /bin/bash

install:
	@cp ./breeder.sh /usr/local/bin/breeder
	@cp -r ./breeder /usr/local/lib/
	@echo Breeder installer. Try to type \'which breeder\'

uninstall:
	@rm -rf /usr/local/bin/breeder /usr/local/lib/breeder
	@echo Breeder uninstalled
