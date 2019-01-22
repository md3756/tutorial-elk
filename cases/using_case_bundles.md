## Using Case Bundles ##

- ## Case Bundles ##
	- A case stands for a method of handling uploading of an arbitrary structure of json
	- Each folder beginning with "case_" contains all the snippets needed to upload data that is structured the way the the folder specifies; for example, the files associated with handling array json, would be found in `/tutorial-elk/cases/logstash/https/case_array_json/` (https://github.com/roni99/tutorial-elk/tree/master/cases/logstash/http/case_array_json)
	- To use whichever bundle desired, place the files in their proper locations, in the case of tutorial/docker-elk
		- for **.conf**, place in `docker-elk/logstash/pipeline`
		- for **.rb**, `place in docker-elk/logstash/ruby_filter_script`
		- for **.json**, place anywhere when used for curl, but match the location of paths specified in filebeat.yml when using filebeat
	- To add new folders to the dockerized stack, read: https://github.com/roni99/tutorial-elk/edit/master/cases/logstash/using_custom_scripts.md

- ## Changing Pipeline ##
	- All pipeline scripts end in `.conf`
	- The file specifying the pipeline in docker elk,  `/path-to/docker-elk/logstash/pipeline/logstash.conf`, is the file: `/usr/share/logstash/config/pipeline.yml`, in the dockerized logstash
	- To change the pipeline script, either edit the docker-compose.yml file to include a volume from any arbitrary folder in localhost to the ELK image (specifically to path written above: /usr/...), or paste the desired pipeline script into docker-elk/logstash/pipeline/logstash.conf (which will require less work, good for testing)

- ## Pitfalls ##
	- If using snippets from any of the cases, be sure that the correct quotation marks are used, including the wrong quotation marks in scripts leads to the stack crashing (e.g. use " ", not “ ”)
