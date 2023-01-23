# Infineon-XMC-Baremetal-with-GNU-Make

In this post, I will explain how to compile code for XMC processors using command-line tools. This is to run on Linux, but it can easily be adapted to Windows also.

Infineon ARM processor lineup is similar to other vendors with many parts. The entry level is a tiny [XMC2GO development board](https://www.infineon.com/cms/en/product/evaluation-boards/kit_xmc_2go_xmc1100_v1/) with a XMC1100-Q024F0064 processor, ARM M0 core of XMC1100 series and 24 pin QFN package. It is so tiny that a lanyard is provided, presumably so that you can tie it somewhere so it does not get lost. The board boasts a [Segger J-Link programmer](https://www.segger.com/products/debug-probes/j-link/) built on a XMC4200 processor (ARM M4) which is not removable... Using a several times more powerful processor as a programmer/debugger for a tiny one might have raised eyebrows several years ago, but seems to have become a trend these days. There are 16 processor pins and power broken out on .1" headers, so you can use it for something useful.

The board is meant to be programmed using DAVE, the Infineon GUI based on Eclipse, running many things besides their development library and arm-none-eabi GCC toolchain in the background. I am not a big fan of GUI's, especially large ones like DAVE that you must install just to check out this tiny processor. Yes, starting up becomes much quicker, but to do something useful, you need to dive into the reference manuals etc, so the GUI is not really helpful. Fortunately Infineon also makes the XMC Periheral Library (or, XMC Lib) available as a separate download.

Here are the required programs:

* [Peripheral library can be downloaded here](https://www.infineon.com/cms/en/product/microcontroller/32-bit-industrial-microcontroller-based-on-arm-cortex-m/?redirId=53843#!tools), but slightly complicated. You need to scroll down to Tools & Software-> "Dave Version XX, DAVE APPs, XMC Lib and example projects" and scroll down to "XMC-Lib" then click download.  
* GCC ARM Embedded Toolchain, [such as downloaded from launchpad.net](https://launchpad.net/gcc-arm-embedded). I have a [blog post on how to setup an environment for this toolchain for STM32](https://aviatorahmet.blogspot.com/2016/04/arm-stm32f10x-programming-with-gcc.html).
* [Segger J-Link tools from Segger](https://aviatorahmet.blogspot.com/2016/04/arm-stm32f10x-programming-with-gcc.html)
* GNU Make is probably already installed if you are reading this.
* The example source code from here.

After installing and checking the programs work:
* Open the "Makefile" and correct the path to LIBROOT where the XMC Lib resides in your computer. You might also need to set the path to arm-none-eabi-gcc and other tools. 
* Open the file `command.jlink` and change the line that says: `loadfile GPIO_TOGGLE.hex` to `loadfile <project directory>.hex` for your current directory.

After adapting the Makefile to your computer installation, all that you will need to to is:
```
make
```
The code should compile and provide you with a `.hex` file that has the same name with your directory. If there are errors, you need to read the output to see where the errors are. Typically there are problems with the location of the XMC Lib location written wrong so that it cannot find the necessary files.

To flash the hex file into your XMC2GO board, you should type:
```
make jflash
```
This will invoke the JLinkExe program to put the on-board programmer into debug mode and call the command file `command.jlink`. This file executes the commands to flash your hex file to the board, reset the processor, and start the execution. If it fails, read its output. Most likely, the name of the hex file does not match.

One word about the linker script. The linker scripts that come in the examples folders of the te symbols `__bss_start__` and `__bss_end__` are not properly defined, although `__bss_start` and `__bss_end` are. This gives linking errors like:
```
(.text+0x68): undefined reference to `__bss_start__'
...
(.text+0x6c): undefined reference to `__bss_end__'
...
exit.c:(.text.exit+0x18): undefined reference to `_exit'
```
So I made small modifications to `linker_script.ld` and defined `__bss_start__` the same as `__bss_start` and `__bss_end__` the same as `__bss_end`, as well as adding the line: `PROVIDE (_exit = __bss_end);`. This completes the compilation without error.

So this is it. It is a short introduction to how you can compile for XMC processors using XMC Lib. It is possible to compile for different processor families. There are three main changes:
* In the Makefile, change the processor type variable to the correct processor: `PTYPE = XMC1100_Q024x0064`, and also change the gcc architecture flags to your requirement: `CFLAGS+= -mcpu=cortex-m0 -mthumb -std=c99` -> Here `-m0` (ARM M0 core) might need to become `-m3` (ARM M3 core) for example.
* Get the correct startup  and linker script for your processor. They can be found from `XMC_Peripheral_Library_v2.1.24/XMCLib/examples/XMC1100_series/GPIO/GPIO_TOGGLE/DAVE/linker_script.ld` and similar locations for your linker script, and `XMC_Peripheral_Library_v2.1.24/CMSIS/Infineon/XMC1100_series/Source/GCC/startup_XMC1100.S` for the startup file. Remember to modiy the linker file as defined above.  **A word of caution here:** `startup_XMC1100.S` and `startup_XMC1100.s` extensions are different. Modify the Makefile build rule for the specific extension.
* In the Makefile, change the JLINK_FLAGS variable to show the current processor.
