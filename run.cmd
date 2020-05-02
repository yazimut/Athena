@ECHO OFF
setlocal

echo Running Athena under the emulator on Windows machine

rem Debug this file.
set DEBUG="false"

rem Current timestamp
set Timestamp=%date:~-4,4%-%date:~-7,2%-%date:~-10,2%^ %time:~-11,2%-%time:~-8,2%-%time:~-5,2%

rem Root directory of the project.
set "ProjectDir=%~dp0"

rem Size of virtual machine RAM in Megabytes.
set "memsz=16"

rem Change this variable to change image of Athena:
rem  "-hda <device or path>" for hard drives;
rem  "-cdrom <device or path>" for CD disks and disk images (.iso).
set "bootable=%ProjectDir%VirtualMachine\Athena.raw"

rem Install package will write installation path to HKLM\SOFTWARE\QEMU\Install_Dir.
For /F "Tokens=2*" %%I In ('Reg Query "HKLM\SOFTWARE\QEMU" /V Install_Dir') Do Set QEMU_DIR=%%J
set "QEMU=%QEMU_DIR%\qemu-system-x86_64.exe"
set "QEMU_ARGS=-gdb tcp::1234 -m size=%memsz% -boot c -rtc base=utc"

rem Install package will write installation path to HKLM\SOFTWARE\Bochs\(Default).
For /F "Tokens=3*" %%I In ('Reg Query "HKLM\SOFTWARE\Bochs" /VE') Do Set BOCHS_DIR=%%J
set "BOCHS=%BOCHS_DIR%\bochsdbg.exe"
set "BOCHS_CONFIG=%ProjectDir%VirtualMachine\Bochs\Windows\Athena.Windows.bxrc"
set "BOCHS_LOG=%ProjectDir%VirtualMachine\Bochs\Windows\%Timestamp%.log"
set "BOCHS_DEBUG_LOG=%ProjectDir%VirtualMachine\Bochs\Windows\%Timestamp%.dbglog"
set "BOCHS_ARGS=-q"

if %DEBUG% == "true" (
	echo Debugging...
	if "%1" == "QEMU" (
		echo "%QEMU%" %QEMU_ARGS% -hda "%bootable%"
	) else if "%1" == "Bochs" (
		echo "%BOCHS%" %BOCHS_ARGS% -f "%BOCHS_CONFIG%" -log "%BOCHS_LOG%"  -dbglog "%BOCHS_DEBUG_LOG%"
	) else (
		echo Error! Wrong virtual machine. Available - QEMU, Bochs.
	)
) else (
	if "%1" == "QEMU" (
		echo Running Athena under the QEMU on Windows machine
		"%QEMU%" %QEMU_ARGS% -hda "%bootable%"
	) else if "%1" == "Bochs" (
		echo Running Athena under the Bochs on Windows machine
		"%BOCHS%" %BOCHS_ARGS% -f "%BOCHS_CONFIG%" -log "%BOCHS_LOG%"  -dbglog "%BOCHS_DEBUG_LOG%"
	) else (
		echo Error! Wrong virtual machine. Available - QEMU, Bochs.
	)
)

endlocal
