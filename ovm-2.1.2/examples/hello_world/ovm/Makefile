

view:
	vsim -view vsim.wlf

sim:
	vsim -do vsim.do -c hello_world

comp:
	vlib work
	vlog +incdir+../../../src  +incdir+../../../src/ovm_pkg.sv hello_world.sv

clean:
	rmdir work /s /q
	del vsim.wlf