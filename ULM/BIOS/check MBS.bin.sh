#!/bin/bash

FSize=$(wc -c < ./bin/MBS.bin)

if [[ $FSize -eq 512 ]]
then
	printf "MBS.bin size is \e[1;32m${FSize}\e[0m bytes.\n"
	exit 0
else
	printf "\e[1;31mError!\e[0m "
	printf "MBS.bin size (\e[1;31m${FSize}\e[0m bytes) "
	printf "is not equal \e[1;32m512\e[0m bytes.\n"
	exit 1
fi

exit 0
