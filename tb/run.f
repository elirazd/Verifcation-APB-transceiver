/*-----------------------------------------------------------------
File name     : run.f
Developers    : Eliraz Deutsch
Description   : run file
Notes         : 
-----------------------------------------------------------------*/
// 64 bit option required for AWS labs
-64

// default timescale
-timescale 1ns/1ns

-uvmhome $UVMHOME

// include directories, starting with UVM src directory
	-incdir ../sv/apb
	-incdir ../sv/tx_rx
	-incdir ../sv/interrupt
	-incdir ../dut
	-incdir ../tb

// compile files
	../sv/apb/apb_pkg.sv
	../sv/apb/apb_if.sv
	../sv/tx_rx/tx_rx_pkg.sv 
	../sv/tx_rx/tx_rx_if.sv
	../sv/interrupt/interrupt_pkg.sv
    ../sv/interrupt/interrupt_if.sv
	// top module for UVM test environment
	tb_top.sv
	// accelerated top module for interface instance
	hw_top.sv

// options
	+UVM_TESTNAME=default_test


    +UVM_VERBOSITY=UVM_LOW

// uncomment for gui 
	//-gui
	//+access+rwc

//RTL
	../dut/apb_transceiver.sv
