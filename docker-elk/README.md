## Dockerized ELK Stack ##

- Included in tutorial-elk is docker-elk (x-pack): https://github.com/deviantony/docker-elk/tree/x-pack

- Differences between tutorial-elk/docker-elk and the original
	- added ruby script folder as well as volume in `docker-compose.yml` to include ruby script folder
	- `tutorial-elk/docker-elk/logstash/pipeline/logstash.config` demonstrates useful filter plugins by default
