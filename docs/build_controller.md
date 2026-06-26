
First, connect to a network. Run:
`docker compose build controller`

Now, make the controller a hotspot, and run:
`docker compose up controller -d`

To diagnose/debug, or run ros2 commands, type:
`docker compose exec controller bash`