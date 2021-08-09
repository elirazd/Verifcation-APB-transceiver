/*-----------------------------------------------------------------
File name     : transciver_mcseqs.sv
Developers    : Eliraz Deutsch
Description   : Multi channel sequence file
Notes         : 
-----------------------------------------------------------------*/

//----------------------------------------------------------------------------
// SEQUENCE: transciver_mcseqs
//----------------------------------------------------------------------------
class transciver_mcseqs extends uvm_sequence;
  
  `uvm_object_utils(transciver_mcseqs)
  `uvm_declare_p_sequencer(transciver_mcsequencer)

  // Protocol sequences
  apb_seq apbseq;
  tx_rx_seq tx_rx_master;
  tx_rx_seq tx_rx_slave;
  
  function new(string name="transciver_mcseqs");
    super.new(name);
  endfunction
 
  task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  

  virtual task body();
  
	`uvm_info(get_name(), "Virtual sequence begins", UVM_LOW)
	
    // Writing 8 words from APB side.
	`uvm_info(get_name(), "Executing 8 APB messeage", UVM_LOW )
	`uvm_do_on_with(tx_rx_master, p_sequencer.rx_seqr, {halt == 1;})
    repeat(8)
	`uvm_do_on_with(apbseq, p_sequencer.apb_seqr, {mode == WRITE; addr == 32'h8;})
	`uvm_do_on_with(tx_rx_master, p_sequencer.rx_seqr, {halt == 0 ;})
	
	// Writing 8 words from tx_rx master side 
	`uvm_info(get_name(), "Executing 8 Tx messeage", UVM_LOW )
	repeat(8)
    `uvm_do_on(tx_rx_slave, p_sequencer.tx_seqr)
	
    // Reading 8 words from APB
	`uvm_info(get_name(), "Executing 8 Rx messeage & read in APB", UVM_LOW )
	repeat(8)
    `uvm_do_on_with(apbseq, p_sequencer.apb_seqr, {mode == READ; addr == 32'h8;})
     
	`uvm_info(get_name(), "Test ended", UVM_LOW)	 
  endtask
  
  task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : transciver_mcseqs

