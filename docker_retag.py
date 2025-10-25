#!/usr/bin/env python3
"""
docker_retag_multi.py
--------------------------------
Reads multiple Docker image tags from 'old_tags.txt',
pulls each image, retags with today's date, and writes
the new tags to 'new_tags.txt'.
"""

import subprocess
from datetime import datetime
import os
from dotenv import load_dotenv

load_dotenv()


OLD_FILE = "old_tags.txt"
NEW_FILE = "new_tags.txt"

def read_image_list(file_path):
    """Read image tags line by line from a text file."""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"{file_path} not found")
    with open(file_path, "r") as f:
        # ignore empty lines and comments
        return [line.strip() for line in f if line.strip() and not line.startswith("#")]

def write_new_tags(file_path, tags):
    """Write the new image tags to output file."""
    with open(file_path, "w") as f:
        for tag in tags:
            f.write(tag + "\n")

def check_user(image_name):
    split_image = image_name.split("/")
    if split_image[1].startswith("dssbpe"):
        return "dssbpe"


def main():
    # subprocess.run(["docker", "login", f"-u={user}", f"-p={password}", "hub.tess.io"], check=True)
    # Read list of original image tags
    images = read_image_list(OLD_FILE)
    print(f"📦 Found {len(images)} image(s) to process")

    new_tags = []
    today = datetime.now().strftime("%Y-%m-%d")

    for img in images:
        print(f"\n➡️ Processing: {img}")

        # Pull the image from Docker Hub (or registry)
        print("   🐳 Pulling image...")
        if check_user(img) == "dssbpe":
            user = os.getenv("dssbpe_uname")
            password = os.getenv("dssbpe_password")
            subprocess.run(["docker", "login", f"-u={user}", f"-p={password}", "hub.tess.io"], check=True)

        subprocess.run(["docker", "pull", img], check=True)

        # Split name and tag
        if ":" in img:
            name, tag = img.split(":", 1)
        else:
            name, tag = img, "latest"

        # Build new image tag with today's date
        new_tag = f"{tag}-{today}"
        new_image = f"{name}:{new_tag}"

        # Retag locally
        print(f"   🏷  Retagging → {new_image}")
        subprocess.run(["docker", "image", "tag", img, new_image], check=True)

        # Add to list
        new_tags.append(new_image)

    # Write all new tags to new_tags.txt
    write_new_tags(NEW_FILE, new_tags)
    print(f"\n✅ All done! New tags saved to: {NEW_FILE}")

if __name__ == "__main__":
    main()
