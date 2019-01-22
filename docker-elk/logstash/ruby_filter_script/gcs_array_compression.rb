def get_fields_from(event, field_name, nest)

	fields = []

	event.get(nest).each_with_index {|hash, key_of_hash|
		fields.push(event.get("#{nest}[#{key_of_hash}][#{field_name}]"))
	}

	return fields

end

# filter method is required for scripts included in ruby plugins
def filter(event)

	# Purpose of script: remove all but specified fields in items list (each item contains google search results in json format)
	# [field] is notation used by event object to access fields from logstash events

	search_links = get_fields_from(event, "link", "[googleImageSearches][items]")
	search_images = get_fields_from(event, "image", "[googleImageSearches][items]")

	# all items contain same data; length of above arrays equal
	# create new hashes equal to the previous amount of items; add only desired fields back to the new hashes, then add all the hashes into a compressed array

	compressed_items = []
	for i in 1...search_links.length do
		item_hash = {}
		# Note: keys remain the same and values remain the same, a purpose is to keep these fields only
		item_hash["link"] = search_links[i]
		item_hash["image"] = search_images[i]
		compressed_items.push(item_hash)
	end

	event.set("[googleImageSearches][items]", compressed_items)

	# Removing arbitrary fields
	event.remove("[googleImageSearches][queries][request][0][cx]")
	event.remove("[googleImageSearches][queries][nextPage][0][cx]")
	event.remove("[googleImageSearches][url]")

	return [event]

end
