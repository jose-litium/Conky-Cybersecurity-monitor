#!/usr/bin/env bats

setup() {
    # Source the script but avoid running the main loop.
    # The script executes `check_dependencies`, `dialog`, and a `while true` loop at the end.
    # We can extract the function we want to test to a separate file or evaluate it.

    # Extract the is_command_installed function from Conky_app-gui.sh
    eval "$(awk '/^function is_command_installed\(\) \{/{flag=1} flag; /^\}/{if(flag){flag=0; exit}}' Conky_app-gui.sh)"
}

@test "is_command_installed returns 0 for existing command" {
    run is_command_installed ls
    [ "$status" -eq 0 ]

    run is_command_installed bash
    [ "$status" -eq 0 ]
}

@test "is_command_installed returns 1 for non-existing command" {
    run is_command_installed nonexistent_command_12345
    [ "$status" -eq 1 ]
}
