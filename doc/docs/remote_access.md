Detailed instructions for SSH'ing into a Pi

1. Check on the Pi whether SSH is enabled
`sudo systemctl status ssh`

If it says inactive(dead), you must enable ssh.

2. Enable SSH:
```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```