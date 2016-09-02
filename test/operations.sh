# 
# function: check for VFIO support.
#
vfio_check() {
    if [ -z "$(ls /sys/kernel/iommu_groups)" ]; then
        echo "/sys/kernel/iommu_groups is empty"
        echo "ERROR: UNVMe requires VFIO, IOMMU, and VT-d enabled"
        exit 1
    fi
    mycmd modprobe vfio-pci
}

# 
# function: bind a specified PCI device to VFIO driver
#
vfio_bind() {
    if [ -e /sys/bus/pci/devices/$1/driver/unbind ]; then
        mycmd "echo $1 > /sys/bus/pci/devices/$1/driver/unbind"
    fi
    mycmd "echo $(lspci -mns $1 | cut -d' ' -f3,4) > /sys/bus/pci/drivers/vfio-pci/new_id"
}

# 
# function: unbind a specified PCI device from VFIO driver
#
vfio_unbind() {
    if [ -h /sys/bus/pci/drivers/vfio-pci/$1 ]; then
        mycmd "echo $1 > /sys/bus/pci/drivers/vfio-pci/unbind"
    fi
}

# 
# function: unbind all NVMe devices from VFIO driver
#
vfio_unbind_all() {
    for d in $(lspci -Dn | grep '0108: ' | cut -d" " -f1); do
        vfio_unbind $d
    done
}

