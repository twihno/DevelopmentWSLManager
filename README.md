# DevelopmentWSLManager

## About this project

The goal of this project was to create a script which makes it ease to quickly create a new, seperate WSL instance.
You can use this script to quickly create a WSL instance which can be used e.g. for a specific project with its special dependencies.
Afterwards you can delete the instance and keep a (relatively) clean operating system.

## Features
- Quickly create a new WSL instance from a .tar image
- Quickly remove/unregister existing WSL instances

## Installation

- Download/Install WSL according to this page: https://docs.microsoft.com/en-us/windows/wsl/install-win10
- Download the current script from this repository

## Create a new WSL instance

### Get an image

#### Option 1: create an image from an exisiting installation
```
wsl --export <NAME> <path-for-the-new-image>.tar
```

#### Option 2: download an image from Microsoft

- Visit https://docs.microsoft.com/en-us/windows/wsl/install-manual
- Download the .appx file for your desired distro
- Change the file extension from .appx to .zip
- Locate the *install.tar.gz* file
- Extract *install.tar.gz* (you should get an *install.tar* file)
- Copy (and if you want rename) *install.tar* to your desired location

#### Option 3: use a custom tar
Use the process described here: https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro

### Create a folder
Create a folder in which you want to install the WSL instance

### Start the script
Start the powershell script and follow the included instructions
NOTE: Your image has to be compatible with the selected WSL version

## Delete an exisiting WSL instance

### Start the script
Start the powershell script and follow the included instructions

## Disclaimer

See LICENSE. I am not affiliated with Microsoft. This project merely exists to facilitate the creation (and deletion) of WSL instances to make development much easier and faster.
