/*-----------------------------------------------------------------
File name     : tb_top.sv
Developers    : Eliraz Deutsch
Description   : testbench top file
Notes         : 
-----------------------------------------------------------------*/

module tb_top;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the UVC's packages
  import apb_pkg::*;
  import tx_rx_pkg::*;
  import interrupt_pkg::*;
  
   // include the multichannel sequencer
  `include "transciver_mcsequencer.sv"

  // include the multichannel sequencer sequences
  `include "transciver_mcseqs.sv"

  // include the transciver scoreboard file
  `include "transciver_scoreboard.sv"
  
  // include the transciver testbench file
  `include "transciver_tb.sv"

  // include the test_lib.sv file
  `include "transciver_test.sv"



  initial begin
    apb_vif_config::set(null,"*.tb.apb.*","vif", hw_top.apb);
	tx_rx_vif_config::set(null,"*.tb.tx_agent.*","vif", hw_top.tx);
	tx_rx_vif_config::set(null,"*.tb.rx_agent.*","vif", hw_top.rx);
	interrupt_vif_config::set(null, "*.int_agent.*", "vif", hw_top.int_if);		

    run_test();
  end

endmodule
