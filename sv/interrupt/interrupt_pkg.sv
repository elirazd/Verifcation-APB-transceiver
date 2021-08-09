/*-----------------------------------------------------------------
File name     : interrupt_pkg.sv
Developers    : Eliraz Deutsch
Description   : IRQ package
Notes         : 
-----------------------------------------------------------------*/

package interrupt_pkg;
	
	import uvm_pkg::*;

	typedef uvm_config_db#(virtual interrupt_if) interrupt_vif_config;
	
	`include "uvm_macros.svh"
	`include "interrupt_data.sv"
	`include "interrupt_monitor.sv"
	`include "interrupt_agent.sv"
	
endpackage

