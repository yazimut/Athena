#!/bin/bash

# Root directory of the project.
ProjectDir=$(dirname $(readlink -e "$0"))

# Uname output
Uname_Kernel=$(uname --kernel-name)
Uname_Nodename=$(uname --nodename)
Uname_KernelRelease=$(uname --kernel-release)
Uname_KernelVersion=$(uname --kernel-version)
Uname_Machine=$(uname --machine)
Uname_Processor=$(uname --processor)
Uname_HardwarePlatform=$(uname --hardware-platform)
Uname_OS=$(uname --operating-system)
WSL="No"

# Prepare any Debian distro with "apt" package manager.
Prepare_Debian ()
{
	sudo apt-get update
	sudo apt-get install -y git make 
	sudo apt-get install -y qemu qemu-kvm qemu-system qemu-user 
	sudo apt-get install -y bochs bochs-doc bochs-term bochs-x bochsbios bximage vgabios
	sudo apt-get install -y nasm
}

printf "Local timestamp: \e[1;33m"
date +%Y-%B-%d\ %a\ %H:%M:%S\ %Z\ \(UTC%:z\)
printf "\e[0m"
echo -e "Configuring host OS for \e[1;32m$(whoami)\e[0m@\e[1;36m$(hostname)\e[0m"
echo ""
echo "Uname output:"
echo " Kernel:               ${Uname_Kernel}"
echo " Nodename:             ${Uname_Nodename}"
echo " Kernel release:       ${Uname_KernelRelease}"
echo " Kernel version:       ${Uname_KernelVersion}"
echo " Machine:              ${Uname_Machine}"
echo " Processor:            ${Uname_Processor}"
echo " Hardware platform:    ${Uname_HardwarePlatform}"
echo " Operating system:     ${Uname_OS}"
uname -a | grep Microsoft > /dev/null
if [[ $? -eq 0 ]]
then
	echo -e "\e[1;36mWarning!\e[0m Running under Windows Subsystem for Linux."
	WSL="Yes"
fi
echo ""

echo -e "Project directory: \e[1;34m${ProjectDir}\e[0m"
echo ""

OS="OS not supported"
if [[ "${Uname_Kernel}" == "Linux" ]]
then
	if [[ -f /etc/debian_version ]]
	then
		# Debian, Ubuntu
		OS="Debian"
	else
		OS="Distro not supported"
	fi
else
	OS="OS not supported"
fi

case ${OS} in
	"Debian")
		echo -e "Preparing \e[1;32mdebian\e[0m system:"
		Prepare_Debian
		if [[ $? -ne 0 ]]
		then
			echo -e "\e[1;31mInstallation failed :( \e[0m"
			exit 5
		fi
		;;
	"Distro not supported")
		echo -e "\e[1;31mYour Linux distro not supported yet :( \e[0m"
		echo -e "\e[1;33mPlease, contact developers ;) \e[0m"
		exit 3
		;;
	"OS not supported")
		echo -e "\e[1;31mYour host OS not supported yet :( \e[0m"
		echo -e "\e[1;33mPlease, contact developers ;) \e[0m"
		exit 2
		;;
	*)
		echo -e "\e[1;31mSomething went wrong :( \e[0m"
		exit 1
		;;
esac

make -C ${ProjectDir} rawdisk
if [[ $? -eq 0 ]]
then
	echo -e "\e[1;32mDone :) \e[0m"
else
	echo -e "\e[1;31mMake crashed :( \e[0m"
	exit 4
fi
exit 0
