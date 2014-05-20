@echo off
set GHDL="C:\Program Files (x86)\Ghdl\bin\ghdl.exe"
set GTKWAVE="C:\Program Files (x86)\gtkwave\bin\gtkwave.exe"

%GHDL% -a -fexplicit --ieee=synopsys ../../src/smart_camera_pack.vhd
if errorlevel 1 goto error 

%GHDL% -a -fexplicit --ieee=synopsys  ../../src/counter.vhd
if errorlevel 1 goto error 

%GHDL% -a -fexplicit --ieee=synopsys ../../src/custom_altpll.vhd
if errorlevel 1 goto error 

%GHDL% -a -fexplicit --ieee=synopsys ../../src/sram_if.vhd
if errorlevel 1 goto error  

%GHDL% -a -fexplicit --ieee=synopsys ../../src/com_if.vhd
if errorlevel 1 goto error

%GHDL% -a -fexplicit --ieee=synopsys ../../src/smart_camera.vhd
if errorlevel 1 goto error

rem Test bench
%GHDL% -a -fexplicit --ieee=synopsys ../../tb/oscillator.vhd
if errorlevel 1 goto error 

%GHDL% -a -fexplicit --ieee=synopsys ../../tb/sram.vhd
if errorlevel 1 goto error 

%GHDL% -a -fexplicit --ieee=synopsys ../../tb/smart_camera_tb.vhd
if errorlevel 1 goto error

%GHDL% -e -fexplicit --ieee=synopsys -v smart_camera_tb
if errorlevel 1 goto error

%GHDL% -r -v -fexplicit --ieee=synopsys smart_camera_tb --vcd=smart_camera.vcd --stop-time=10us
if errorlevel 1 goto error
rem --no-run  --stop-delta=100 --stack-max-size=100Mo --disp-tree --disp-time 
%GTKWAVE% smart_camera.vcd
goto end
:error
echo errors
:end
pause