transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {floating_point_adder_6_1200mv_85c_slow.vo}

vlog -vlog01compat -work work +incdir+D:/IITB\ Files/Sem\ IV/VLSI\ Design\ Lab/Lab2 {D:/IITB Files/Sem IV/VLSI Design Lab/Lab2/testbench.v}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
