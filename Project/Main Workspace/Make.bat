:: turn off meaningless output
@echo off

:: set path
set path=.\;C:\yagarto\bin;
set gcc_a=-g -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -I . -I ..\GeneralInterface -mfloat-abi=hard
set gcc_c=-g -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -I . -I ..\GeneralInterface -mfloat-abi=hard -O0 -c
set gcc_l=--script=Linker.ld

:: compile all source files
cd Source\GeneralInterface
for %%f in (*.c) do arm-none-eabi-gcc %gcc_c% -o ..\c_%%~nf.o %%~nf.c
for %%f in (*.asm) do arm-none-eabi-as %gcc_a% -o ..\a_%%~nf.o %%~nf.asm
cd ..\HardwareInterface
for %%f in (*.c) do arm-none-eabi-gcc %gcc_c% -o ..\c_%%~nf.o %%~nf.c
for %%f in (*.asm) do arm-none-eabi-as %gcc_a% -o ..\a_%%~nf.o %%~nf.asm
cd ..\SoftwareInterface
for %%f in (*.c) do arm-none-eabi-gcc %gcc_c% -o ..\c_%%~nf.o %%~nf.c
for %%f in (*.asm) do arm-none-eabi-as %gcc_a% -o ..\a_%%~nf.o %%~nf.asm
cd ..\ClockInterface
for %%f in (*.c) do arm-none-eabi-gcc %gcc_c% -o ..\c_%%~nf.o %%~nf.c
for %%f in (*.asm) do arm-none-eabi-as %gcc_a% -o ..\a_%%~nf.o %%~nf.asm
cd ..\ToneInterface
for %%f in (*.c) do arm-none-eabi-gcc %gcc_c% -o ..\c_%%~nf.o %%~nf.c
for %%f in (*.asm) do arm-none-eabi-as %gcc_a% -o ..\a_%%~nf.o %%~nf.asm
cd ..\..

:: link everything
arm-none-eabi-ld %gcc_l% -o Project.elf Source\*.o

:: convert elf to hex for flashing
arm-none-eabi-objcopy -O ihex Project.elf Project.hex

:: convert elf to axf for debugging
copy Project.elf "Debug\Debug.axf"

:: keep only files needed for submission
del *.elf
del Source\*.o

:: pause to let user see compilation results
pause
