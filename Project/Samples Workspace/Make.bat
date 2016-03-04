:: turn off meaningless output
@echo off

:: set path
set path=.\;C:\yagarto\bin;
set gcc_a=-g -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
set gcc_c=-g -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -O0 -c
set gcc_l=--script=Linker.ld

:: compile all files
cd Source
for %%f in (*.asm) do arm-none-eabi-as %gcc_a% -o a_%%~nf.o %%~nf.asm
for %%f in (*.c) do arm-none-eabi-gcc %gcc_c% -o c_%%~nf.o %%~nf.c
cd ..

:: link everything
arm-none-eabi-ld %gcc_l% -o Project.elf Source\*.o

:: convert elf to hex for flashing
arm-none-eabi-objcopy -O ihex Project.elf Project.hex

:: keep only files needed for submission
del *.elf
del Source\*.o

:: pause to let user see compilation results
pause
