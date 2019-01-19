def parse_to_json_shallow(string)
	# Expecting parallel json objects (meaning objects would be siblings if wrapped in one json object) 
	# Returning a list of json objects as strings (will be decoded by logstash)
	characters_from_file = string.split("")
	stack_json_bracket = Array[]

	index_of_current_object = 0
	json_objects = Array[]

	# For sake of example, parse only highest level objects
	characters_from_file.each_with_index {|character, i|
		case character
		when "{"
			# Keep track of new object so string can be reformed when finding corresponding closing bracket
			if stack_json_bracket.length == 0
				index_of_current_object = i
			end
			stack_json_bracket.push(character)
		when "}"
			stack_json_bracket.pop
			# If the stack is empty, an entire object has been located, so turn to string
			# To account for deeper objects, repeat the lenght check below for different lengths; need bucket array of length equal to depth of deepest object
			if stack_json_bracket.length == 0
				object_as_string = characters_from_file[index_of_current_object, i + 1].join("")
				json_objects.push(object_as_string)
			end
		end
	}

	return json_objects

end

def filter(event)
	# Assuming message contains json
	json_objects = parse_to_json_shallow(event.get("[message]"))
	event.set("[message]", json_objects)
	event.set("[debug][message_length]", json_objects.length)
	return [event]
end
