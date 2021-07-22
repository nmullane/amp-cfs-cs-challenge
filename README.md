# AMP-Challenge-NASA-cFS-Checksum
Patching a broken checksumming application running in [cFS](https://github.com/nasa/cfs)

## Introduction
This challenge is designed to replicate a scenario where the flight software on a spacecraft needs to be patched without replacing the entire binary executable. [cFS](https://github.com/nasa/cfs) is a flight software framework developed by Goddard Space Flight Center. cFS provides a common framework for flight software apps to run on. To interact with cFS we are using the [COSMOS](https://cosmosc2.com) ground system software which will enable you to view telemetry from cFS.

## Vulnerability
For this challenge a specific cFS app, the checksum app, needs to be patched. The checksum app performs regular checksums of the cFS executable itself as well as memory and data on the system. In this scenario the checksum for the Core Flight Executive (a component of cFS) is being checked incorrectly increments an error counter which is displayed in the COSMOS ground system.

## Software
We have provided two prebuilt binary files titled `core-cpu1` for a cFS build with a patched and vulnerable checksum app. These binaries are within the `cfs_checksum_patched/` and `cfs_checksum_vuln/` directories respectively. Both of these directories also contain the source cFS code used to generate the two binaries in the `cFS/` subdirectory.

## OS
The challenge is configured to run within Docker using an Ubuntu 20.04 container to run the cFS binary (16.04 and 18.04 have also been verified to work) and a second container to run the COSMOS ground system.

## Setup
There is no hardware necessary for this challenge. Make sure you have docker compose installed on your computer.

Run `docker-compose -f docker-compose-vuln.yaml up` to launch the cFS binary and the COSMOS ground system.

When the COSMOS launcher opens, press the COSMOS Demo icon in the top row. This will connect COSMOS with cFS and open display screens to view the status of the checksum app and cFS as a whole.

![image](https://user-images.githubusercontent.com/4342051/126688827-da41b85b-5ffd-444f-b2fc-7c6d1a345938.png)

To verify the behavior of the checksum app, look at the cfe Core Checksum Error Count. This will increment every minute if the checksum app is vulnerable.

![image](https://user-images.githubusercontent.com/4342051/126689214-f71d6884-d6be-4776-a34a-fb93eddfd1ef.png)

# cFS Additional Information
## cFS Architecture
The cFS Framework provides two components, The Operating System Abstraction Layer (OSAL) and The Platform Support Package (PSP), which enable cFS apps to run no matter what the target hardware or operating system is as long as the target is supported by OSAL and has a PSP. This allows cFS apps to be incredibly modular and reusable by different missions. 

The core behavior of cFS that the apps utilize comes from cFE, The core Flight Executive. This component provides a messaging framework, time management, and startup/shutdown capabilities.
![image](https://user-images.githubusercontent.com/4342051/126690139-fe8a32a1-c8c5-4ec9-b8b4-76b9ebe0b96c.png)

The cFS apps define the behavior of the system. The apps are responsible for controlling all subsystems, reading sensor data, communicating with the ground, and all other tasks. 
![image](https://user-images.githubusercontent.com/4342051/126689875-d8313180-3ce6-4b4d-ac77-593b6aff2403.png)

The Checksum app is intended to perform periodic checks of the cFS executable itelf, the apps that are running, and memory to protect against bit flips due to radiation or other types of corruption. What's relevant to this challenge is the checksum app will compute a baseline checksum for the cFE core. Then the checksum app will periodically recalculate this baseline and compare it against itself to see if it has changed. If the calculated value is different, the checksum app will continue accumulating an error count until the calculated becomes the same as the baseline again or a new baseline is forced to be recomputed.

The vulnerable version of the checksum app calculates the baseline properly, but when it compares the calculated value against the baseline it adds 1 to the calculated value to make it unequal to the baseline and throw an error.
