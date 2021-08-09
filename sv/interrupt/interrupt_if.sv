/*-----------------------------------------------------------------
File name     : interrupt_if.sv
Developers    : Eliraz Deutsch
Description   : IRQ interface file
Notes         : 
-----------------------------------------------------------------*/

interface interrupt_if (input logic clock, reset);

	timeunit 1ns;
	timeprecision 100ps;

	import interrupt_pkg::*;
	import uvm_pkg::*;

	// APB signals:
	logic		irq;

  	// signal for transaction recording
  	bit monstart;


 // Collect transaction:
 task collect_transaction(output bit irq);

	@(negedge clock)

	// trigger for transaction recording
      	monstart = 1'b1;
	
	`uvm_info("INTERRUPT_IF", "collect transactions", UVM_HIGH)
	
	irq = irq;

	// reset trigger
      	monstart = 1'b0;

 endtask : collect_transaction


endinterface
