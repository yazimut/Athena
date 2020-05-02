#!/bin/bash
echo Running Athena under the emulator on Linux machine

# Debug this file.
DEBUG="false"

# Current timestamp
Timestamp=$(date +%Y-%B-%d\ %H-%M-%S)

# Root directory of the project.
export ProjectDir=$(dirname "$(readlink -e "$0")")

# Distro name
Distro="Undefined"
getDistro()
{
	# Ubuntu?
	tmp=$(cat /etc/issue.net | grep Ubuntu)
	if [[ $? -eq 0 ]]; then Distro="Ubuntu"; fi
}
getDistro

# Size of virtual machine RAM in Megabytes.
memsz=16

# Change this variable to change image of Athena:
#  "-hda <device>" for hard drives;
#  "-cdrom <device or path>" for CD disks and disk images (.iso).
bootable="${ProjectDir}/VirtualMachine/Athena.raw"

QEMU=qemu-system-x86_64
QEMU_ARGS="-gdb tcp::1234 -m size=${memsz} -boot c -rtc base=utc"

BOCHS=bochs
BOCHS_CONFIG="${ProjectDir}/VirtualMachine/Bochs/Linux/${Distro}/Athena.${Distro}.bxrc"
BOCHS_LOG="${ProjectDir}/VirtualMachine/Bochs/Linux/${Distro}/${Timestamp}.log"
BOCHS_DBGLOG="${ProjectDir}/VirtualMachine/Bochs/Linux/${Distro}/${Timestamp}.dbglog"
BOCHS_AGRS="-q"

if [[ $# -eq 0 ]]
then
	echo Error! Wrong virtual machine. Available - QEMU, Bochs.
else
	if [[ "${DEBUG}" == "true" ]]
	then
		# Debugging...
		echo Debugging...
		if [[ "$1" == "QEMU" ]]
		then
			echo "${QEMU}" ${QEMU_ARGS} -hda "${bootable}"
			exit 0
		elif [[ "$1" == "Bochs" ]]
		then
			echo "${BOCHS}" ${BOCHS_AGRS} -f "${BOCHS_CONFIG}" -log "${BOCHS_LOG}" -dbglog "${BOCHS_DBGLOG}"
			exit 0
		else
			echo Error! Wrong virtual machine. Available - QEMU, Bochs.
		fi
	else
		if [[ "$1" == "QEMU" ]]
		then
			echo Running Athena under the QEMU on Linux machine
			"${QEMU}" ${QEMU_ARGS} -hda "${bootable}"
			exit 0
		elif [[ "$1" == "Bochs" ]]
		then
			echo Running Athena under the Bochs on Linux machine
			"${BOCHS}" ${BOCHS_AGRS} -f "${BOCHS_CONFIG}" -log "${BOCHS_LOG}" -dbglog "${BOCHS_DBGLOG}"
			exit 0
		else
			echo Error! Wrong virtual machine. Available - QEMU, Bochs.
		fi
	fi
fi
