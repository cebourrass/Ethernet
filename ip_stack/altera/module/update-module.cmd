set project="..\..\..\..\..\design\dream_camera_fpga_qsys\submodules\mac_if"
rem set project="..\..\..\..\..\design\dream_camera_fpga\submodules\mac_if"
if exist %project%\ del /Q/S %project% > nul:
if exist %project% rd %project%
move /-Y mac_if %project%