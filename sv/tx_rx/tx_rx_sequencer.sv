/*-----------------------------------------------------------------
File name     : tx_rx_sequencer.sv
Developers    : Eliraz Deutsch
Description   : TX RX sequencer
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: tx_rx_sequencer
//
//------------------------------------------------------------------------------

class tx_rx_sequencer extends uvm_sequencer #(tx_rx_item);

  `uvm_component_utils(tx_rx_sequencer)

  function new(string name, uvm_component parent);   
    super.new(name, parent);     // important!!
  endfunction

endclass : tx_rx_sequencer


