Athena - a new modern progressive x86_64 Operating System.



################################################################
                       Table of contents                        
################################################################

	0. Table of contents
	1. Hardware requirements
	2. Software requirements for development
	3. Contacts and support
	4. How to build?






################################################################
                     Hardware requirements                      
################################################################

* x86_64 architecture based CPU
* 16 Megabytes of RAM
* 64 Megabytes of physical memory
* Standard keyboard
* VGA compatible monitor



################################################################
             Software requirements for development              
################################################################

* OS:	Windows 10 x64 version 1909
     	Ubuntu 20.04 x64
* QEMU 5.0.0
* Bochs 2.6.11

[ Windows ]
* Windows subsystem for Linux
* (Optional) Git for Windows 2.26.2 with Git 2.17.1
And a relevant requirements for chosen Linux distro.

[ Ubuntu ]
* GNU bash 4.4.20(1)-release
* GNU coreutils 8.28
* Apt 1.6.12
* Git 2.17.1
* GNU Make 4.1



################################################################
                      Contacts and support                      
################################################################

If you have any questions or suggestions contact the developers:
	Y.Azimut e-mail (main):		y.azimut@mail.ru
	Athena on GitHub:			https://github.com/yazimut/Athena.git
	Y.Azimut on GitHub:			https://github.com/yazimut
	Y.Azimut on VK:				https://vk.com/yazimut



################################################################
                         How to build?                          
################################################################

Firstly, you have to install tools to build the Athena.
	* If your host-machine is a Linux based OS (including Windows subsystem 
	  for Linux), just run a `host-prepare.sh` file from a terminal. 
	  Warning: script requires superuser privileges!
	* If your host-machine is a Windows OS, you have to do some preparing 
	actions:
		1. Install "Windows Subsystem for Linux" and appropriate Linux 
		   distro from a Microsoft Store (for example Ubuntu).
		2. Install QEMU virtual machine. You need "qemu-subsystem-x86_64" and 
		   "qemu-img" tools - they are usually included in a QEMU installer.
		   It is good for simple launching the Athena.
		3. Install Bochs virtual machine. Is is good for debugging the Athena.
		4. Reboot a system.
		5. Correct the paths to virtual machines executables in file 
		   "run.cmd", if they are not the same with yours.
		6. Launch your Linux distro, go through the user registration 
		   procedure, and repeat this instruction as for Linux based OS.

Now you can develop and build the Athena.

To build just execute `make`.

To launch the system in emulator build and execute `make install`. Then:
	* If you are under the Linux based OS execute `./run.sh` from terminal.
	* If you are under the Windows OS execute `run.cmd` from a CMD or 
		PowerShell.
Remember that "run" scripts requires a virtual machine name as a parameter. 
Run script to view available virtual machine names.
Execution example: `<run> <Virtual machine name>`
	`./run.sh QEMU`
	`./run.sh Bochs`
