/*-----------------------------------------------------------------
File name     : interrupt_data.sv
Developers    : Eliraz Deutsch
Description   : IRQ item file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: interrupt_data
//
//------------------------------------------------------------------------------

class interrupt_data extends uvm_sequence_item;

	rand logic 	irq;

	`uvm_object_utils_begin(interrupt_data)
		`uvm_field_int(irq, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "interrupt_data");
		super.new(name);
	endfunction

endclass
