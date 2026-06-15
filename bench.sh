#!/bin/bash

# Reset
sudo apt remove -y curl net-tools lsof > /dev/null 2>&1

echo "Baseline: Individual install"
time {
    sudo apt install -y curl > /dev/null 2>&1
    sudo apt install -y net-tools > /dev/null 2>&1
    sudo apt install -y lsof > /dev/null 2>&1
}

# Reset
sudo apt remove -y curl net-tools lsof > /dev/null 2>&1

echo "Optimized: Batched install"
time {
    sudo apt install -y curl net-tools lsof > /dev/null 2>&1
}
