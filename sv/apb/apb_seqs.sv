/*-----------------------------------------------------------------
File name     : apb_seqs.sv
Developers    : Eliraz Deutsch
Description   : APB sequens file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: sequence - base sequence with objections from which 
// all sequences can be derived
//
//------------------------------------------------------------------------------
class apb_seq extends uvm_sequence#(apb_packet);
  
  	rand apb_mode 	mode;
	rand int 			addr;
  
  // Required macro for sequences automation
	`uvm_object_utils_begin(apb_seq)
		`uvm_field_enum(apb_mode, mode, UVM_ALL_ON)
		`uvm_field_int(addr, UVM_ALL_ON)
	`uvm_object_utils_end

  // Constructor
  function new(string name="apb_seq");
    super.new(name);
  endfunction

	virtual task body();
		apb_packet apb_pkt;
		`uvm_info(get_name(), "APB sequence - Executing packet sequence", UVM_LOW)

			// Data constructor:
			apb_pkt = apb_packet::type_id::create("apb_pkt");
			
			// Data randomization:
			if(!apb_pkt.randomize())
			`uvm_error(get_name(), "Error = apb datd is not randomized correctly")

			// Override parameters by the user:
			apb_pkt.mode = mode;
			apb_pkt.addr = addr;

			// Send sequence:
			`uvm_send(apb_pkt)
	endtask

endclass : apb_seq
