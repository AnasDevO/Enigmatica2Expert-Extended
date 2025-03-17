import os

# Get the current directory
current_directory = os.getcwd()

# Function to capitalize words after underscores
def format_filename(name):
    parts = name.split("_")
    return parts[0].capitalize() + "".join(part.capitalize() if part and part[0].isalpha() else "_" + part for part in parts[1:])

# List all .toml files (remove the extension and format)
filenames = [format_filename(f[:-5]) for f in os.listdir(current_directory) if f.endswith(".toml")]

# Write to a text file with double quotes
with open("filenames.txt", "w") as file:
    file.write("[" + ", ".join(f'"{name}"' for name in filenames) + "]")

print("Filenames saved in filenames.txt")