c:
cd C:\ovm-2.1.2\examples\hello_world\ovm
vlib work
vlog -f compile_questa_sv.f
vsim -do vsim.do -c top
quit -f
pause