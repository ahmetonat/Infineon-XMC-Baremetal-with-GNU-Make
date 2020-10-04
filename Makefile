#######################################################
# Important:
# Modify the lines below defining: TOOLROOT and LIBROOT
#  to match their locations on your own computer!
#######################################################


# compilation flags for gcc and gas:
CFLAGS  = -O1 -g
ASFLAGS = -g 

# Object file list:
OBJS= main.o
OBJS += xmc1_gpio.o  xmc_gpio.o 
OBJS += startup_XMC1100.o system_XMC1100.o
# startup_XMC100.S  with a capital 'S'

ELF_FILE=$(notdir $(CURDIR)).elf
MAP_FILE=$(notdir $(CURDIR)).map
BIN_FILE=$(notdir $(CURDIR)).bin
HEX_FILE=$(notdir $(CURDIR)).hex

CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
AR=arm-none-eabi-ar
AS=arm-none-eabi-as
OBJCOPY=arm-none-eabi-objcopy

# Library path
LIBROOT=/home/onat/elektronik/ARM/Compiler/XMC_Peripheral_Library_v2.1.24

# Paths of various components in the library specified here:
DEVICE=$(LIBROOT)/CMSIS/Infineon/XMC1100_series/
FAMILY=$(LIBROOT)/XMCLib
CORE=$(LIBROOT)/CMSIS/Core
INFINEON= $(LIBROOT)/CMSIS/Infineon/XMC1100_series

# Search paths for standard files
vpath %.c
vpath %.c $(FAMILY)/src
vpath %.S $(INFINEON)/Source/GCC/
vpath %.c $(INFINEON)/Source/

PTYPE = XMC1100_Q024x0064
LDSCRIPT = ./linker_script.ld

LDFLAGS+= -T$(LDSCRIPT) -mthumb -mcpu=cortex-m0 -Wl,-Map=$(MAP_FILE) 
# AO!: Check if  -nostdlib is needed.

CFLAGS+= -mcpu=cortex-m0 -mthumb -std=c99
CFLAGS+= -I$(DEVICE)/Include -I$(CORE)/Include -I$(FAMILY)/inc -I.

CFLAGS+= -D$(PTYPE) 

# Prepare the .bin binary file:
OBJCOPYFLAGS = -O binary

JLINK_FLAGS=-device XMC1100-64 -if SWD -speed 4000 -autoconnect 1 -CommanderScript 

JLINK_FILE=command.jlink

# Build executable 
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

#$(BIN_FILE) : $(ELF_FILE)
#	$(OBJCOPY) $(OBJCOPYFLAGS) $< $@

$(ELF_FILE) : $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS) $(LDFLAGS_POST)

# compile and generate dependency info
%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@
	$(CC) -MM $(CFLAGS) $< > $*.d

#%.o: %.s #Attention! .s and .S files need different rules.
%.o: %.S
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	rm -f $(OBJS) $(OBJS:.o=.d) $(ELF_FILE) $(MAP_FILE) $(CLEANOTHER) $(BIN_FILE)

jflash: $(HEX_FILE)
	JLinkExe  $(JLINK_FLAGS) $(JLINK_FILE)

# pull in dependencies

-include $(OBJS:.o=.d)

