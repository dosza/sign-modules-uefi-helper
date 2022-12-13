#!/bin/bash 



if [ $# -lt 2 ]; then
	echo "Few args!"
    echo "Usage: sign-module.sh [name] [modules...]
        Sample:
            sign-modules.sh VirtualBox vboxdrv"
	exit 1
fi

checkConditions(){
    [ ! -e $PWD/MOK.der ] &&
    [ ! -e $PWD/MOK.priv ]
}

generateModuleCert(){
    if checkConditions; then  
        openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=$1/" 
        sudo mokutil --import MOK.der 
        echo 'Need reboot'
        exit 1
    fi
}

signCurrentKernel(){
    for module in ${@}; do
        modinfo -n $module
        sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv  ./MOK.der $(modinfo -n $module)
    done
}


signModules(){
	for module in ${@}; do
		signCurrentKernel $module
	done
}

echo "Trying to sign the module(s): ${@:2} ..."
generateModuleCert "$1"
signModules ${@:2}