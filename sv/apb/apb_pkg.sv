/*-----------------------------------------------------------------
File name     : apb_pkg.sv
Developers    : Eliraz Deutsch
Description   : apb package
Notes         : 
-----------------------------------------------------------------*/

package apb_pkg;
	import uvm_pkg::*;

	typedef enum {READ, WRITE} apb_mode;

	typedef uvm_config_db#(virtual apb_if) apb_vif_config;

	`include "uvm_macros.svh"
	`include "apb_packet.sv"
  `include "apb_seqs.sv"
  `include "apb_sequencer.sv"
	`include "apb_monitor.sv"
  `include "apb_driver.sv"
	`include "apb_agent.sv"

endpackage
