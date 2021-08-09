/*-----------------------------------------------------------------
File name     : apb_if.sv
Developers    : Eliraz Deutsch
Description   : APB interface file
Notes         : 
-----------------------------------------------------------------*/

interface apb_if (input clock, input reset );
timeunit 1ns;
timeprecision 100ps;

import uvm_pkg::*;
import apb_pkg::*;

  // Actual Signals
  logic             psel;
  logic             penable;
  logic         	pwrite;
  logic 	[3:0]	paddr;
  logic		[31:0]	pwdata;
  logic		[31:0]	prdata;

  // signal for transaction recording
  bit monstart, drvstart;
  
  task reset_port();
    @(posedge reset);
    psel <= 1'b0;
	penable <= 1'b0;
	pwrite <= 1'b0;
	paddr <= 4'bz;
	pwdata <= 32'b0;
    disable send_to_dut;
  endtask
  
  // Gets a packet and drive it into the DUT
  task send_to_dut(input   	bit [3:0]	addr,
							bit [31:0] data,
							apb_mode mode);
	if(mode == WRITE) begin
		@(posedge clock);
		// trigger for transaction recording
		drvstart = 1'b1;
		// Start to send packet - After one time cycle Select the slave DUT and write
    	paddr <= addr;
		pwdata <= data;
		pwrite <= 1'b1;
		psel <= 1'b1;
		//Enable start packet signal
		@(posedge clock);
		penable <= 1'b1 ;
		//Finish to send packet
		@(posedge clock);
		//Reset sel and enable
		penable <= 1'b0 ;
		psel <= 1'b0;
		// reset trigger
		drvstart = 1'b0;
	end
	
	if(mode == READ) begin
		@(posedge clock);
		// trigger for transaction recording
		drvstart = 1'b1;
		// Start to send packet - After one time cycle Select the slave DUT and write
    	paddr <= addr;
		pwrite <= 1'b0;
		psel <= 1'b1;
		//Enable start packet signal
		@(posedge clock);
		penable <= 1'b1 ;
		//Finish to send packet
		@(posedge clock);
		//Reset sel and enable
		penable <= 1'b0 ;
		psel <= 1'b0;
		// reset trigger
		drvstart = 1'b0;
	end
  endtask : send_to_dut

  // Collect Packets
  task collect_packet(output  	bit [3:0]	addr,
								bit [31:0] 	data,
								apb_mode mode);
								
    //Monitor looks at the bus on posedge (Driver uses negedge)
	@(negedge clock iff (psel && penable))
    // trigger for transaction recording
    monstart = 1'b1;
    `uvm_info("APB IF", "collect packets", UVM_HIGH)
    addr = paddr;
	// Collect write data
	if (pwrite) begin
	mode = WRITE;
    data <= pwdata;
	end
	if (!pwrite) begin
		mode = READ;
		@(posedge clock);
		data <= prdata;
	end
    // reset trigger
    monstart = 1'b0;
  endtask : collect_packet

endinterface : apb_if

