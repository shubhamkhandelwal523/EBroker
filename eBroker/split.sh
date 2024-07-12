#!/bin/bash


#This file is for development purpose we are not responsible if it does not work.
destination_folder="splits/"



if [ "$1" = 'size' ]; then
    du -h "$destination_folder"
    exit 0
fi


if [ "$1" = 'clear' ]; then
    if [ -d "$destination_folder" ]; then
        # Remove all files in the folder
        rm -f "$destination_folder"/*
        echo "Splits cleared!!!"
    else
        echo "The folder $destination_folder does not exist."
    fi
    exit 0
fi

if [ "$1" = 'i-latest' ]; then
    if [ -d "$destination_folder" ]; then
        # Remove all files in the folder
     if [ -d "$destination_folder" ]; then
         # Use find and ls to get the latest file
         latest_file=$(find "$destination_folder" -type f -exec ls -t {} + | head -n 1)

         if [ -n "$latest_file" ]; then

           echo "Installing: $latest_file"
             adb  -s "$2" install "$latest_file"
         else
             echo "No files found in $destination_folder."
         fi
     else
         echo "The folder $destination_folder does not exist."
     fi
    else
        echo "The folder $destination_folder does not exist."
    fi
    exit 0
fi


flutter build apk --split-per-abi --no-tree-shake-icons
source_file="build/app/outputs/flutter-apk/app-armeabi-v8a-release.apk"
current_date=$(date +"%e %b")





if [ ! -d "$destination_folder" ]; then
    mkdir -p "$destination_folder"
fi


counter=0
while [[ -e "$destination_folder$filename" ]]; do

      if [ "$counter" -eq 0 ]; then
    filename="eBroker ${current_date}.apk"
        else
  filename="eBroker ${current_date} (${counter}).apk"
          fi
    ((counter++))
done
echo "done!! "$destination_folder$filename"";

cp "$source_file" "$destination_folder$filename"
#install app
while true; do
    read -p "Do you wish to install this app? [yes/no] " yn
    case $yn in
        [Yy]* ) adb  -s "$2" install "$destination_folder$filename"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
