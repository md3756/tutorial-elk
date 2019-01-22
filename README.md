# Methods for Bulk Uploading JSON of Various Structure to ELK #
___
- ## Purpose ##
	- Documentation of different methods of creating separate events from a file containing JSON data
___
- ## Intro ##
	- Below, there are a few cases of how input json data might be structured, however there are many more cases than listed
	- Using Case Bundles
		- For each case, there is a corresponding folder in tutorial-elk/cases containing code samples
		- **Each case folder is a bundle that contains a formatting of json, as well as all code snippets required to handle parsing the data; to test the various methods of uploading data, make changes to docker-elk using the snippets found in a case folder, run docker-elk, then upload data found in the case folder (for example, through a curl command)**
	- Although there are many cases not covered, by using logstash, an approach to prepare data for storage is possible given any input structure (below, the point: Logstash > One line request > case 3, is a great example of versatility of logstash)
	- Testing docker-elk
		- To start, run docker-elk, by changing directory to docker-elk, and running:
			> `docker-compose up`
		- After the stack loads, enter Kibana through a browser (Kibana listens on port 5601)
		- Run command (attach the file: https://github.com/roni99/tutorial-elk/blob/master/cases/logstash/http/case_array_json/array_wrapped_objects.json):
			> `curl localhost:5000 -d @array_wrapped_objects.json`
		- Visualize the results on Kibana
		- When done, press `ctrl + c` twice, then run:
			> `docker-compose down`
___
- ## Understanding Cases ##
	- **Logstash**
		- One line request through curl
			- **case 1**: Target JSON object is the only object in the file:
				>`curl -H "content-type: application/json" localhost:5000 -d @file.json`
			- **case 2**: Target JSON objects are in an array, and there is only one highest level object in file
				- Approach
					- In logstash pipeline file, include:
						> `split { field => "fieldName" }`
				- keep in mind: split will create an event for each array item; in the events they are contained in, each item will be placed into a field named fieldName (arbitrary)
				- Although the highest level obect would be parsed correctly if approach above is not taken, outputing to elasticsearch would result in one document containing all the target data
				- command:
					> `curl -H "content-type: application/json" localhost:5000 -d @file.json`
			- **case 3**: Target JSON objects are in parallel
				- Parallel objects: objects that would all be siblings if they were wrapped in one object (example file: {} {} {})
				- In the command below, note how there is no header specified; this is because the json header would result in only the first json object being parsed
				- Approach
					- make a ruby script that places only the highest level json objects into a string array (https://github.com/roni99/tutorial-elk/blob/master/cases/logstash/http/case_parallel_json/bulk_json_splitter.rb)
					- at this point, the approach becomes a case 2 approach, where split filter plugin is used in the logstash pipeline
					- Note: each event created from split is contains a json object as a string; manual json parsing would be necessary at this point if logstash did not automatically parse the json (which is also why locating only the highest level json objects in the first step sufficed)
				- command:
					> `curl localhost:5000 -d @file.json`
				- the approach to workaround this case is the best display of the versatility of logstash in this document
		- **Filebeat**
			- This agent automatically handles splitting one file into multiple events; which was the goal of the actions above when running curl
			- The approach below handles two cases: parallel JSON and single objects
			- **general case**
				- Approach
					- install filebeat: https://www.elastic.co/guide/en/beats/filebeat/current/setup-repositories.html
					- In filebeat.yml, under filebeat.inputs.paths, include the path to a json file
					- under "filebeat.input," add the following:
					  > multiline.pattern: "^{"		# Any open bracket to the far left
					  
					  > multiline.negate: true		# Add any string not matching the pattern
					  
					  > multiline.match: after		# Add to string where pattern was located
					  
					  > multiline.max_lines: 0		# Prevents truncation
					  
					- under "filebeat.processors," add the following:
					  > - decode_json_fields:
					  
					  >     fields: ["message"]
					  
					  >     process_array: false
					  
					  >     max_depth: 1
					  
					  >     target: ""
					  
					  >     overwrite_keys: false
					  
					- start filebeat with command:
						> `sudo ./filebeat -e`
	- **Elasticsearch**
		- elasticsearch bulkapi handles minified bulk json in one command
		- the file must be strucutured so each line of json is preceded by a line of elasticsearch metadata
		- an example of an upload to elasticsearch
			- Command:
				> `curl -u elastic:changeme -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/_bulk?pretty' --data-binary @shakespeare.json`
			- example file (highlighted is what would become one elastic document):
				> …
				> {"index":{"_index":"shakespeare","_id":9001}}
				>{"type":"line","line_id":26344,"play_name":"Coriolanus","speech_number":59,"line_number":"3.1.152","speaker":"CORIOLANUS","text_entry":"Ill give my reasons,"}
				> …

___
- ## Technical Details ##
	- including json header in curl
		- if a header of "content-type: application/json" included in curl, there is no need to include json filter plugin, parsing occurs automatically (this is one example of versatility of logstash; there are multiple locations to include options that complete the same task)
		- including header of "content-type: application/json" will also remove the message field; which may restrict some options, such as the custom ruby script that parses json (to keep the message field, do not include the header)
		- the header will also cause only the first object in a file to be parsed (if planning to upload multiple items while also including header, wrapping the objects in a dummy array and including the split filter in the logstash pipeline is a robust workaround)
___
- ## Notes ##
	- One major part of upload process handled by Elasticsearch automatically, creating mappings, is not covered by this documentation
	- Parts of data aggregation process covered (**bold**)
		- gathering data
		- **uploading data to Logstash**
		- **filtering data (through Logstash plugins and through ruby scripts)**
		- creating mappings in Elasticsearch
		- creating visualizations in Kibana
		
