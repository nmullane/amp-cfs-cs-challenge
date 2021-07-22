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

