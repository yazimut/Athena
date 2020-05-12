#!/bin/bash

FSize=$(wc -c < ./bin/UEFI.elf)

if [[ $FSize -le 65536 ]]
then
	printf "UEFI.elf size is \e[1;32m${FSize}\e[0m bytes.\n"
	exit 0
else
	printf "\e[1;31mError!\e[0m "
	printf "UEFI.elf size (\e[1;31m${FSize}\e[0m bytes) "
	printf "is grater than \e[1;32m65536\e[0m bytes.\n"
	exit 1
fi

exit 0
