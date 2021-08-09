/*-----------------------------------------------------------------
File name     : tx_rx_if.sv
Developers    : Eliraz Deutsch
Description   : Tx-Rx interface file
Notes         : 
-----------------------------------------------------------------*/
//------------------------------------------------------------------------------
//
// CLASS: tx_rx_if
//
//------------------------------------------------------------------------------
interface tx_rx_if (input clock, input reset );
	timeunit 1ns;
	timeprecision 100ps;

	import tx_rx_pkg::*;
	import uvm_pkg::*;

	// Actual Signals
	logic       [31:0] data;
	logic            valid;
	logic       	 halt;


  // signal for transaction recording
  bit monstart, drvstart;
  

  // Collect Packets
  task collect_packet(output bit [31:0]  fdata, bit fhalt, fvalid);
    //Monitor looks at the bus on posedge (Driver uses negedge)
      @(negedge clock )
	// trigger for transaction recording
		monstart = 1'b1;
		
		if (!halt & valid) begin
			`uvm_info("TX_RX_IF", "collect packets", UVM_HIGH)
			// Collect Header
			fdata = data;
			fhalt = halt;
			fvalid = 1'b1;
		end
		else begin
			fdata = 32'bx;
			fhalt = halt;
			fvalid = 1'b0;
		end
		// reset trigger
		monstart = 1'b0;
  endtask : collect_packet

endinterface : tx_rx_if

