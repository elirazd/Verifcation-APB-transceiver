/*-----------------------------------------------------------------
File name     : tx_rx_item.sv
Developers    : Eliraz Deutsch
Description   : Tx Rx item file
Notes         : 
-----------------------------------------------------------------*/
//------------------------------------------------------------------------------
//
// tx_rx item enums, parameters, and events
//
//------------------------------------------------------------------------------
//typedef enum bit { BAD_VALID, GOOD_VALID } valid_t;
//typedef enum bit { HALT, CONTINUE } halt_t;
//------------------------------------------------------------------------------
//
// CLASS: tx_rx_item
//
//------------------------------------------------------------------------------

class tx_rx_item extends uvm_sequence_item;     

	// Physical Data
	rand logic	[31:0]	data;
	rand logic			halt;
	bit					valid;

  // Control Knobs
//  rand valid_t validity;
//  rand halt_t halt_type;

	// UVM macros for built-in automation - These declarations enable automation
	// of the data_item fields 
	`uvm_object_utils_begin(tx_rx_item)
  		`uvm_field_int(data, UVM_ALL_ON)
		`uvm_field_int(halt, UVM_ALL_ON)
		`uvm_field_int(valid, UVM_ALL_ON)
	`uvm_object_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "tx_rx_item");
    super.new(name);
  endfunction : new
  
  // Constrain for mostly GOOD_VALID packets
//  constraint default_validity { validity dist {BAD_VALID := 1, GOOD_VALID := 18}; }
  // Constrain for mostly CONTIUE packets
//  constraint default_halt_type { halt_type dist {HALT := 1, CONTINUE := 20}; }
  
endclass : tx_rx_item
