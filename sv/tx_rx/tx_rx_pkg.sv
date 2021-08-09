/*-----------------------------------------------------------------
File name     : tx_rx_pkg.sv
Developers    : Eliraz Deutsch
Description   : tx rx package
Notes         : 
-----------------------------------------------------------------*/

package tx_rx_pkg;
	import uvm_pkg::*;
	typedef enum bit { SLAVE, MASTER } drv_type;
	
	typedef uvm_config_db#(virtual tx_rx_if) tx_rx_vif_config;

	`include "uvm_macros.svh"
	`include "tx_rx_item.sv"
	`include "tx_rx_monitor.sv"
	`include "tx_rx_sequencer.sv"
	`include "tx_rx_seqs.sv"
	`include "tx_rx_driver.sv"
	`include "tx_rx_agent.sv"

endpackage
