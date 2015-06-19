README for Installation of Openstack on Multiple Nodes each with single network interface card


Extracting the files:
	Download the the complete tar file which includes all the packages or the partial tar file which excludes packages.
		Complete tar link:	" "
		Partial tar link:	"https://drive.google.com/folderview?id=0B6fU9KPg7WgyfndqU01aSk1pLVFFQl9aR1I1NFBEYno2VnlIdlpaZzZtbEgzWE1ESTVfNHM&usp=sharing"

	Continue with the below steps after extracting the tar file i your working directory.

Hardware Requirements:
	- 3 Physical machines (laptops)
	- Each with one NIC
	- One USB port or Cdrom for installations

Installation Process:
	It has been classified in two main stages
		1. Installation of base (prerequisits) system on top of which actual intsallation will be done.
		   The base sofware installation can be done using preseeding. Since we are using 3 different machines with each requiring
		   slightly different configuration than other, we've created 3 different preseed.cfg file each for Controller, Compute and
		   Network node respectively. Only difference between these is in the "d-i preseed/late_command string" section. Another script
		   has been added to the init.d scripts using the "d-i preseed/late_command string" section in such a way that it will run only
		   on the first boot of the system. All the three preseed.cfg files are attached.

		   Below is the generalized process:
			a. Download basic small operating system with no additional packages. For Eg: debian-7.8.0-amd64-netinst.iso
			   It can be downloaded from below link:
				   http://cdimage.debian.org/mirror/cdimage/archive/7.8.0/amd64/iso-cd/debian-7.8.0-amd64-netinst.iso
			b. Latest initrd.gz and vmlinuz will be needed for preseeding purpose. You can download the same from below link.
				   http://ftp.debian.org/debian/dists/stable/main/installer-i386/current/images/hd-media/
			c. Create a file with name syslinux.cfg. Copy paste the below lines into that file without double quotes.
			   "default vmlinuz
			    append initrd=initrd.gz preseed/file=/hd-media/preseed.cfg locale=en_US.UTF-8 console-keymaps-at/keymap=us \   
			    languagechooser/language-name=English countrychooser/shortlist=IN vga=normal keyboard-configuration/xkb-keymap=us --"
			d. Now create the preseeed.cfg file as per your requirements. (Attached are the 2 preseed.cfg files that we used).
			   You can refer to the below link for any information related to preseed.cfg
				https://www.debian.org/releases/stable/amd64/apb.html.en
			e. Take a PenDrive and run the below commands to make the PenDrive bootable for installing the base system.
			   Note:install-mbr command is contained in the mbr Debian package.
				mkdosfs command is contained in the dosfstools Debian package.
				install the syslinux and mtools packages on your system.

					#umount /path/where/the/USB/is/mounted;
					#dd if=/dev/zero of=/dev/USBdev bs=1024 count=2; sync;
					#fdisk /dev/sdX
						o
						n
						a
						w
					#install-mbr /dev/sdX;
					#mkdosfs /dev/sdX1;
					#syslinux /dev/sdX1;
					#mount /dev/sdX1 /mnt;
					#cp vmlinuz /mnt/;
					#cp initrd.gz /mnt/;
					#cp syslinux.cfg /mnt/;
					#cp debian-7.8.0-amd64-netinst.iso /mnt/;
					#cp preseed.cfg /mnt/;
					#cp Comp1 /mnt/;
					#cp Cont1 /mnt/;
					#cp Net1 /mnt/;
					#cp CompInstSt.sh /mnt/;
					#cp ContInstSt.sh /mnt/;
					#cp NetInstSt.sh /mnt/;
					#cp -r ~/Downloads/OpenStack /mnt/;
					#umount /mnt;
			f. Now you can remove the PenDrive and connect it to any machine you wish to do the installation on and select it as
			   the boot device from the BIOS to start with the preseeded installation procedure.

		2. Here we start with the actual installation of OpenStack.
		   Please note that the order of installation is very important and no steps should be performed out of the given below order.
		   During the Preseeding step itself we have copied the necessary files to appropriate locations in all the three machines.
		   So only thing to do is execute the below commands in the given order and then follow the instructions provided within the
		   running script.

			a. On the Controller node execute:
				#sh /home/sandip/OpenStack/Controller/Scripts/ControllerInstallScript2.sh
			b. On the Compute node execute:
				#sh /home/sandip/1Compute/Scripts/ComputeInstallScript2.sh
			c. On the Network node execute:
				#sh /home/sandip/Network/Scripts/NetworkInstallScript2.sh

Miscelleneous Info:
	Please follow the below link guide or the attached pdf manual for any clarifications or any additional information that will be needed.
		- http://docs.openstack.org/juno/install-guide/install/apt-debian/content/
		- http://docs.openstack.org/juno/install-guide/install/apt/content/
