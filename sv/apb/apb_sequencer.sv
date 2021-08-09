/*-----------------------------------------------------------------
File name     : apb_sequencer.sv
Developers    : Eliraz Deutsch
Description   : APB Sequencer file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: apb_sequencer
//
//------------------------------------------------------------------------------

class apb_sequencer extends uvm_sequencer #(apb_packet);

  `uvm_component_utils(apb_sequencer)

  function new(string name, uvm_component parent);   
    super.new(name, parent);     // important!!
  endfunction

endclass : apb_sequencer


