/*-----------------------------------------------------------------
File name     : transciver_tb.sv
Developers    : Eliraz Deutsch
Description   : lab06_vif router testbench instantiates YAPP UVC
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: transciver_tb
//
//------------------------------------------------------------------------------

class transciver_tb extends uvm_env;

  // component macro
  `uvm_component_utils(transciver_tb)

  // Protocol agent's
  apb_agent 		apb;
  tx_rx_agent 		tx_agent;
  tx_rx_agent 		rx_agent;
  interrupt_agent	int_agent;

  // Virtual Sequence
  transciver_mcseqs mcseqs;
  
  // Virtual Sequencer
  transciver_mcsequencer mcsequencer;
  
  // Transciver Scoreboard
  transciver_scoreboard scoreboard;
 
  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	apb = apb_agent::type_id::create("apb", this);
	tx_agent = tx_rx_agent::type_id::create("tx_agent", this);
	tx_agent.set_drv(SLAVE);
	rx_agent = tx_rx_agent::type_id::create("rx_agent", this);
	tx_agent.set_drv(MASTER);
	int_agent = interrupt_agent::type_id::create("int_agent", this);
	mcsequencer = transciver_mcsequencer::type_id::create("mcsequencer", this);
	mcseqs = transciver_mcseqs::type_id::create("mcsequs", this);
	scoreboard = transciver_scoreboard::type_id::create("scoreboard", this);
  endfunction : build_phase
  
    // UVM connect_phase
  function void connect_phase(uvm_phase phase);

    // Virtual Sequencer Connections
    mcsequencer.apb_seqr = apb.sequencer;
    mcsequencer.rx_seqr = rx_agent.sequencer;
	mcsequencer.tx_seqr = tx_agent.sequencer;

	// Connect the TLM ports from the APB & tx-rx and Channel UVCs to the scoreboard
	apb.monitor.apb_out.connect(scoreboard.sb_apb);
	tx_agent.monitor.tx_rx_out.connect(scoreboard.sb_tx);
	rx_agent.monitor.tx_rx_out.connect(scoreboard.sb_rx);
	int_agent.interrupt_mon.int_out.connect(scoreboard.sb_irq);
  endfunction : connect_phase

endclass : transciver_tb
