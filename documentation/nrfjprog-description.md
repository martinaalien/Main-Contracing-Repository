# Programming the nRF52833 DKs

## Needed software
To be able to program the nRF Development Kits (DKs) you need to have the [J-Link Software and Documentation Pack](https://www.segger.com/downloads/jlink/#J-LinkSoftwareAndDocumentationPack) and [nRF Command Line Tools](https://www.nordicsemi.com/Software-and-tools/Development-Tools/nRF-Command-Line-Tools) installed. 

The nRF Command Line Tools does not support ARM architecture, which Raspberry Pi 4 uses. To overcome this issue, a Shell script is created, named ``nrfjprog.sh``. Before you use the `nrfjprog.sh`script, make sure it is executable by stepping in to the folder were it is located and run the following command:

    chmod +x nrfjprog.sh

## Interfacing with the hardware

The `nrfjprog.sh` script expects either two or three arguments, depending on wich action you want to perform. 

For flashing related actions use this command:

    nrfjprog <action> [hexfile] [DEVICE] 

For other actions use this command:

    nrfjprog <action> [DEVICE]

## Actions
The `action` argument can be the following actions:
### --reset
Performs a soft reset by setting the SysResetReq bit of the AIRCR register of the core. The core will run after the operation.
### --pin-reset
Performs a pin reset. Core will run after the operation.
### --erase-all
Erases all user available program flash memory and the UICR page.
### --flash
Flashing the device with the hex file given by the ``hexfile`` argument. 
### --flash-softdevice
Flashes the device with the softdevice by passing the path of the softdevice as an argument to the ``nrfjprog.sh`` call.
### --rtt
Starts a Real Time Transfer session.
### --gdbserver
Starting gdb for debugging. 

## Hexfile
This parameter is the full path to the hex file you want to flash the device with.

## Device
The script accepts the following devices:

* `WB1`: Wristband number 1
* `WB2`: Wristband number 2
* `WB3`: Wristband number 3

It is important to keep the syntax correct, or else the script will fail and ask you to use valid arguments.