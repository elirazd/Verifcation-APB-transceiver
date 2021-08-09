/*-----------------------------------------------------------------
File name     : transciver_mcsequencer.sv
Developers    : Eliraz Deutsch
Description   : Multi sequencer exe file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: transciver_mcsequencer
//
//------------------------------------------------------------------------------

class transciver_mcsequencer extends uvm_sequencer;

   apb_sequencer 	apb_seqr;
   tx_rx_sequencer  rx_seqr;
   tx_rx_sequencer  tx_seqr;

  `uvm_component_utils(transciver_mcsequencer)

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : transciver_mcsequencer

