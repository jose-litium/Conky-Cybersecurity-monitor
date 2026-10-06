#!/usr/bin/env bats

setup() {
    # Extract the check_user_systemd function from Conky_app-gui.sh
    eval "$(awk '/^check_user_systemd\(\) \{/{flag=1} flag; /^\}/{if(flag){flag=0; exit}}' Conky_app-gui.sh)"

    dmsg() {
        echo "dmsg: $1"
    }
    log() {
        echo "log: $1"
    }
}

@test "check_user_systemd returns 0 when systemctl --user succeeds" {
    systemctl() {
        return 0
    }
    run check_user_systemd
    [ "$status" -eq 0 ]
}

@test "check_user_systemd fails and exits 1 when systemctl --user fails" {
    systemctl() {
        return 1
    }
    run check_user_systemd
    [ "$status" -eq 1 ]
    [[ "$output" == *"dmsg: User-level systemd is not available."* ]]
    [[ "$output" == *"log: ERROR: User systemd not available"* ]]
}
