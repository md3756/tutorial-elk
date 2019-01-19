## Using Custom Scripts ##

___
- Parts of process
	1. Creating the scripts
		- in any arbitrary location, create a folder (named ruby_filter_script in this tutorial) that will hold ruby scripts for the pipeline
		- every ruby script used by logstash must have a method named "filter" defined as:

			> def filter(event);
			> 	...method body...;
			> end
			
		- without the filter method, there is no way to access the event object that enables easy manipulation of data in logstash events
	2. Placing scripts in the Logstash docker image
		- edit a file, in the root of docker-elk, named docker-compose.yml
		- in filebeat.yml -> services.logstash.volumes, include the volume (paths were arbitrarily chosen in step 1):
			> ./logstash/ruby_filter_script:/usr/share/logstash/ruby_filter_script:ro
		- Note: left of the colon in the volume is the location of the script folder created in step 1, right of the colon is the location that the folder is found in the logstash image (keep in mind the location to the right, as it will necessary to find the folder soon)
	3. Using scripts in Logstash
		- in the pipeline file (by default "/{path-to}/docker-elk/logstash/pipeline"), in the filter section, include the ruby plugin, like so:

			> ruby {
			>	path => "/{image-path-to}/{script}.rb"
			> }

		- replace (literally) image-path-to with the path specified in docker-compose.yml, specifically the path to the right of the colon in the volume created in step 2
		- replace script with the name of any script found in image-path-to
___
- Avoiding Pitfalls
	- do not include "/" after tail folders in volumes in docker-compose
	- Change permission of all folders included in volumes to 777


___
- Notes
	- In step three, "Using scripts in Logstash", the folder "/{path-to}/docker-elk/pipeline", was included by the createors of the docker-elk repo in a process almost identical to the process mentioned above (pipeline is an arbitrary name as well, the focus is that the docker-compose.yml file points to the right location for the pipeline)
	- (Extra) If including a ruby script, make sure the ruby plugin is in the correct spot in the filter section of the pipeline file; for example, if the script removes certain sub-fields from fields, and if those fields are in an array (and if each object is intended to become an event), the ruby plugin will come after a split plugin so the script is applied to each object resulting from the split plugin
