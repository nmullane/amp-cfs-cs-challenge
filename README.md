# AMP-Challenge-NASA-cFS-Checksum
Patching a broken checksumming application running in [cFS](https://github.com/nasa/cfs)

## Introduction
This challenge is designed to replicate a scenario where the flight software on a spacecraft needs to be patched without replacing the entire binary executable. [cFS](https://github.com/nasa/cfs) is a flight software framework developed by Goddard Space Flight Center. cFS provides a common framework for flight software apps to run on. To interact with cFS we are using the [COSMOS](https://cosmosc2.com) ground system software which will enable you to view telemetry from cFS.

## Vulnerability
For this challenge a specific cFS app, the checksum app, needs to be patched. The checksum app performs regular checksums of the cFS executable itself as well as memory and data on the system. In this scenario, the checksum for the Core Flight Executive (a component of cFS) is being checked incorrectly and increments an error counter displayed in the COSMOS ground system.

## Software
We have provided two prebuilt binary files titled `core-cpu1` for a cFS build with a patched and vulnerable checksum app. These binaries are within the `cfs_checksum_patched/` and `cfs_checksum_vuln/` directories respectively. Both of these directories also contain the source cFS code used to generate the two binaries in the `cFS/` subdirectory if you intend to build from source.

You can build and run cFS from source by running the following commands in the `cfs_checksum_patched/` and `cfs_checksum_vuln/` directories.
```bash
git submodule init
git submodule update
make
make install
cd build/exe/cpu1
./core-cpu1
```

## OS
The challenge is configured to run within Docker using an Ubuntu 20.04 container to run the cFS binary (16.04 and 18.04 have also been verified to work) and a second container to run the COSMOS ground system.

## Setup
There is no hardware necessary for this challenge.

The best way to install and run COSMOS is through a docker container. The COSMOS docker container documentation can be found [here](https://github.com/BallAerospace/cosmos-docker). Unfortunately, COSMOS is very GUI based, so when launching in Docker you need to have an XServer on your local machine. If you're running linux, you probably already have an XServer installed. If you're running Windows, COSMOS recommends installing [MobaXterm](https://mobaxterm.mobatek.net).

### Linux Setup
* Install docker compose
* You will also need an XServer although one is probably already installed

Run the following commands in a terminal to launch cFS and COSMOS.
```bash
# Enables the cosmos docker container to connect to the xserver and display the gui
xhost +

# Launch cFS and COSMOS docker containers
docker-compose -f docker-compose-vuln.yaml up
```
You can also just run the cFS executable locally by going into the `cfs_checksum_vuln/` directory and running `./core-cpu1`.

### Windows Setup
* Install Docker Desktop
* Install and Configure MobaXterm
  - Launch MobaXTerm
  - Select Settings -> Configuration, then X11, then set X11 remote access to: full. Click Ok.
  - Click the large Session button, and then click Shell, and click Ok.
  - Note the Line: Your DISPLAY is set to X.X.X.X:X:0. Make sure you have DISPLAY environment variable set in your host shell to this value.

Run the following commands in a terminal to launch cFS and COSMOS.
```bash
# Allow COSMOS to connect to MobaXterm
set DISPLAY=<My XServer's IP Address ie 10.0.0.1:0.0>

# Launch cFS docker container
docker run --volume=.\cfs_checksum_patched:/cfs --sysctl fs.mqueue.msg_max=3000 --network host -it ubuntu:16.04 bash -c "cd /cfs && ./core-cpu1"

# Launch COSMOS docker container
winpty docker run --net=host --rm -e DISPLAY -e QT_X11_NO_MITSHM=1 ballaerospace/cosmos
```
### Running

When the COSMOS launcher opens, press the COSMOS Demo icon in the top row. This will connect COSMOS with cFS and open display screens to view the status of the checksum app and cFS as a whole.

*Note:* Make sure you press the COSMOS Demo icon after cFS has launched otherwise the telemetry enable command will not be received by cFS and you will not see any data in COSMOS.

![image](https://user-images.githubusercontent.com/4342051/126688827-da41b85b-5ffd-444f-b2fc-7c6d1a345938.png)

To verify the behavior of the checksum app, look at the cfe Core Checksum Error Count. This will increment every minute if the checksum app is vulnerable.

![image](https://user-images.githubusercontent.com/4342051/126689214-f71d6884-d6be-4776-a34a-fb93eddfd1ef.png)

# cFS Additional Information
## cFS Architecture
The cFS Framework provides two components, The Operating System Abstraction Layer (OSAL) and The Platform Support Package (PSP), which enable cFS apps to run no matter what the target hardware or operating system is as long as the target is supported by OSAL and has a PSP. This allows cFS apps to be incredibly modular and reusable by different missions. 

The core behavior of cFS that the apps utilize comes from cFE, The core Flight Executive. This component provides a messaging framework called the software bus, time management, startup/shutdown capabilities, among other things as well.
![image](https://user-images.githubusercontent.com/4342051/126690139-fe8a32a1-c8c5-4ec9-b8b4-76b9ebe0b96c.png)

The cFS apps define the behavior of the system. The apps are responsible for controlling all subsystems, reading sensor data, communicating with the ground, and all other tasks. 
![image](https://user-images.githubusercontent.com/4342051/126689875-d8313180-3ce6-4b4d-ac77-593b6aff2403.png)

## Checksum App
The Checksum app is intended to perform periodic checks of the cFS executable itelf, the apps that are running, and memory to protect against bit flips due to radiation or other types of corruption. What's relevant to this challenge is the checksum app will compute a baseline checksum for the cFE core. Then the checksum app will periodically recalculate this baseline and compare it against itself to see if it has changed. If the calculated value is different, the checksum app will continue accumulating an error count until the calculated checksum becomes the same as the baseline again or a new baseline is forced to be recomputed.

The vulnerable version of the checksum app calculates the baseline properly, but when it compares the calculated value against the baseline it adds 1 to the calculated checksum to make it unequal to the baseline and the app will throw an error.
