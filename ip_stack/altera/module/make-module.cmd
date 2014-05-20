rem mkmodule tool
rem author T. TIXIER
rem mail ttixier@free.fr
rem date 28/11/2011
rem description
rem generate module according to altera specification
@echo off
cls
rem MODULE name
set ip=mac_if

if exist %ip% del /Q/S %ip% > nul:
if exist %ip% rd %ip%

mkdir %ip%
copy %ip%_hw.tcl  %ip% > nul:
copy ..\..\..\..\counter\vhdl\src\*.vhd %ip% > nul:
copy ..\..\src\*.vhd %ip% > nul:
