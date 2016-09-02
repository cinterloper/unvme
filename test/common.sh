
trap 'exit 1' TERM
export EXIT_PID=$$
#
# function: print usage and exit
#
myusage() {
    echo -e "${USAGE}"
    exit 1
}
#
# function: print error and exit
#
myerror() {
    echo "ERROR: $*"
    kill -s TERM ${EXIT_PID}
    exit 1
}
# 
# function: echo and execute command, and exit on error
#
mycmd() {
    #echo -e "$(date +%T)> $*"
    eval $*
    if [ $? -ne 0 ]; then myerror "EXIT"; fi
}

# 
# function: print binding status of the PCI argument list
#
print_map() {
    for d in $(lspci -Dn | grep '0108: ' | cut -d" " -f1); do
        m=$(find /sys/bus/pci/drivers -name $d -printf %h)
        case $m in 
        */nvme)
            m="mapped to $(ls /sys/bus/pci/devices/$d/nvme)"
            ;;

        */vfio-pci)
            m='enabled for UNVMe'
            ;;

        esac

        d="$(echo $d | sed 's/^0000://')"
        echo "$d $(lspci -vs $d | sed '/Subsystem:/!d;s/.*: //') - ($m)"
    done
}


