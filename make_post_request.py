"""Sample request code."""


# Step 1: Build the image: docker build -t float-decoder -f api.Dockerfile .  
# Step 2: Run the docker compose: docker compose -f api.docker-compose.yml up -d --build
import requests as rq
from pathlib import Path
import requests
import json

url = "http://localhost:8000/decode_float/6903014"
file_dir = r"mockfiles_6903014"


# Open all the files we want to decode.
files = [("files", (str(Path(file_path).name), open(file_path, "rb"), "text/plain")) for file_path in Path(file_dir).glob("*.txt")]


# Open the info and meta JSONS for the float we want to decode.
with open(r"mockfiles_6903014/info_json.json") as file:
   float_info = json.loads(file.read())

with open(r"mockfiles_6903014/meta_info.json") as file:
   meta_info = json.loads(file.read())


# Example Extra args, used to pass to the decoder and overwrite the default configuration.
extra_args = {"DIR_OUTPUT_XML_FILE" : "/mnt/data/output/xml/",}

data = {
    "float_metadata": json.dumps({
        "float_info": float_info,
        "float_meta_info": meta_info,
    }),
    "configuration_override": json.dumps(extra_args),  # optional
}

# Make the request.
response = requests.post(url, files=files, data=data)
print(response.status_code)
print(response)



# Close the files we opened earlier.
for _, (name, file_obj, _) in files:
    file_obj.close()


# Save the response content as a ZIP file
if response.status_code == 200:
    with open("output.zip", "wb") as f:
        f.write(response.content)
    print("ZIP file saved as 'output.zip'")
else:
    print("Request failed with status:", response.status_code)
    print(response.text)