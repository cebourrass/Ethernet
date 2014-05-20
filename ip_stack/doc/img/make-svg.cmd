rem @author(Alexis Landrault et Thierry Tixer)
rem @date(2012-09-24)
rem @version(1.0-4-g7c7bcae on heads/master)
@echo off
cd %~d1\%~p1
%~d1
dot -Gcharset=latin1 -Tsvg %~n1.dot > %~n1.svg
dot -Gcharset=latin1 -Tpng %~n1.dot > %~n1.png
pause