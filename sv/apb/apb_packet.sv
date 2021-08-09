/*-----------------------------------------------------------------
File name     : apb_packet.sv
Developers    : Eliraz Deutsch
Description   : apb packets file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: apb_packet
//
//------------------------------------------------------------------------------

class apb_packet extends uvm_sequence_item;     

  // Physical Data
  rand logic 	[3:0]	addr;
  rand logic	[31:0]	data;
  rand apb_mode mode;

  // UVM macros for built-in automation - These declarations enable automation
  // of the data_item fields 
  `uvm_object_utils_begin(apb_packet)
  		`uvm_field_int(addr, UVM_ALL_ON)
		`uvm_field_int(data, UVM_ALL_ON)
		`uvm_field_enum(apb_mode, mode, UVM_ALL_ON)
	`uvm_object_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "apb_packet");
    super.new(name);
  endfunction : new

  // Default Constraints
  constraint default_addr 	{ addr >= 0; addr < 16; }
  
endclass : apb_packet
