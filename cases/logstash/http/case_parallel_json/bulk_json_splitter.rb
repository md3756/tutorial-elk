def parse_to_json_shallow(string)
        # Expecting parallel json objects (meaning objects would be siblings if wrapped in one json object)
        # Returning a list of json objects as strings (will be decoded by logstash)
        all_chars = string.split("")
        stack_json_bracket = Array[]

        index_of_current_object = 0
        json_objects = Array[]
        indices = []

        # For sake of example, parse only highest level objects
        all_chars.each_with_index {|character, i|
                case character
                when "{"
                        # Keep track of new object so string can be reformed when finding corresponding closing bracket
                        if stack_json_bracket.length == 0
                                index_of_current_object = i
                                indices.push(i)
                        end
                        stack_json_bracket.push(character)
                when "}"
                        stack_json_bracket.pop
                        # If the stack is empty, an entire object has been located, so turn to string
                        # To account for deeper objects, repeat the length check below for different lengths; need bucket array of length equal to depth of deepest object
                        if stack_json_bracket.length == 0
                                object_as_string = ""
                                cursor = index_of_current_object
                                while cursor < all_chars.length() and cursor < i do
                                    # Concatenation with << for better time performance
                                    object_as_string << all_chars[cursor]
                                    cursor += 1
                                end
                                if cursor < all_chars.length and all_chars[cursor] == "}"
                                        object_as_string << "}"
                                end
                                json_objects.push(object_as_string)
                        end
                end

        }

        return json_objects

end

# Filter is a mandatory method
def filter(event)
        # Assuming message contains json
        json_objects = parse_to_json_shallow(event.get("[message]"))
        event.set("[message]", json_objects)
        return [event]
end
