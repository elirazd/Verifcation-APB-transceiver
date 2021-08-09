/*-----------------------------------------------------------------
File name     : tx_rx_seqs.sv
Developers    : Eliraz Deutsch
Description   : Tx Rx prtocol SEQUENCE file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: base sequence with objections from which 
// all sequences can be derived
//
//------------------------------------------------------------------------------
class tx_rx_seq extends uvm_sequence#(tx_rx_item);
  
	rand int halt=-1;
    
	// Required macro for sequences automation
	`uvm_object_utils_begin(tx_rx_seq)
  		`uvm_field_int(halt, UVM_ALL_ON)
	`uvm_object_utils_end

	constraint halt_constraint {halt inside {[-1:1]};}

	// Constructor
	function new(string name="tx_rx_seq");
		super.new(name);
	endfunction

  
  	virtual task body();
		tx_rx_item 	item;

		`uvm_info(get_name(), "tx rx item executed", UVM_LOW)

			// Data constructor:
			item = tx_rx_item::type_id::create("item");
			
			// Data randomization:
			if(!item.randomize())
			`uvm_error(get_name(), "Error = rx_tx datd is not randomized correctly")
			
			// Override parameters by the user:
			if(halt != -1)
				item.halt = halt;
			`uvm_info(get_type_name(), $sformatf("Halt assinged :\n halt=%d", item.halt), UVM_LOW)

			// Send sequence:
			`uvm_send(item)
			
	endtask

endclass : tx_rx_seq
