import json
import sys

def get_keys(obj, keys):
    # Recursive function to extract unique keys from nested dictionaries and lists
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key not in keys:
                # If the key is not already in the keys dictionary, add it
                keys[key] = get_keys(value, {})
            elif isinstance(value, (dict, list)):
                # If the value is a dictionary or a list, recursively call get_keys
                get_keys(value, keys[key])
    elif isinstance(obj, list):
        for item in obj:
            if isinstance(item, (dict, list)):
                # If the item is a dictionary or a list, recursively call get_keys
                get_keys(item, keys)
    else:
        # Base case: if the object is neither a dictionary nor a list, return None
        return None
    return keys

data = []
unique_keys = {}

# Check if the file path is provided as a command line argument
if len(sys.argv) > 1:
    file_path = sys.argv[1]
else:
    # Ask the user to enter the file path
    file_path = input("Enter the file path: ")

with open(file_path, 'r') as file:
    decoder = json.JSONDecoder()
    s = file.read()
    while s:
        # Decode the JSON object and get the index of the next object
        obj, idx = decoder.raw_decode(s)
        data.append(obj)
        # Extract unique keys from the object and store them in unique_keys dictionary
        get_keys(obj, unique_keys)
        s = s[idx:].lstrip()

# Write the unique keys to a file in JSON format
with open('nestformat.json', 'w') as file:
    json.dump(unique_keys, file, indent=2)