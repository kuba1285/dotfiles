#!/bin/bash

# Get a random image file from the background image folder.
IMAGE_FILE=$(find ~/Pictures/ -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.png" \) | shuf -n 1)

# Get the path to the sddm backgrounds folder.
SDDM_BACKGROUNDS_FOLDER="/usr/share/sddm/themes/sugar-candy/Backgrounds"

# Create a symbolic link to the random image file in the sddm backgrounds folder (overwrite with the force flag).
ln -sf "$IMAGE_FILE" "$SDDM_BACKGROUNDS_FOLDER/randomWallpaper"
