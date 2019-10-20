#/usr/bin/env bash

# REPORT=/var/log/hw-address-inventory.csv
REPORT=/tmp/hw-address-inventory.csv

# Functions
check_iproute2() {
    which ip > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR[-]: Missing ip command, install iproute2"
        exit 2
    fi
}

preapre_file () {
    rm $REPORT > /dev/null 2>&1
    echo "# Inventory for $(hostname -f)" > $REPORT
}

get_interfaces() {
    ip link | awk -F: '$0 ~"[^0-9]"{print $2; getline}' | cut -d ' ' -f2 | grep -v '^lo$'
}

get_mac_address() {
    if [ $# -ne 1 ]; then
        echo "ERROR[-]: Missing interface name parameter for get_mac_address function"
        exit 3
    fi
    net_inferface=$1
    ip link show $net_inferface | grep link/ether | awk {'print $2'}
}


# Main
check_iproute2
preapre_file
for net_interface in $(get_interfaces); do
   mac_address=$(get_mac_address $net_interface)
   echo "$net_interface;$mac_address" >> $REPORT
done
echo "Check CSV report at $REPORT"
