

Note: If you get permission errors, build with `sudo`

First, connect to a network. Run:
`docker compose build controller`

Now, make the controller a hotspot, and run:
`docker compose up controller -d`

To diagnose/debug, or run ros2 commands, type:
`docker compose exec controller bash`


Clearing docker containers(Old):
`docker container prune -f`


## Troubleshooting

If you're getting "invalid for another 1d 16h 48 min 58s", that is an indication of a date issue.
Date issues? Follow: [fixing date issues](/doc/fixing_date_issues.md)