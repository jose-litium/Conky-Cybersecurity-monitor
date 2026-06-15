mkdir -p /tmp/sudoers_test
echo "Cmnd_Alias CONKY_RKHUNTER = /usr/bin/rkhunter --update, /usr/bin/rkhunter --propupd, /usr/bin/rkhunter --check --sk" > /tmp/sudoers_test/conky
echo "%usergroup ALL=(ALL) NOPASSWD: CONKY_RKHUNTER" >> /tmp/sudoers_test/conky
visudo -c -f /tmp/sudoers_test/conky
