/*-----------------------------------------------------------------
File name     : tx_rx_monitor.sv
Developers    : Eliraz Deutsch
Description   : tx rx mointor file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: tx_rx_monitor
//
//------------------------------------------------------------------------------

class tx_rx_monitor extends uvm_monitor;

  // Collected Data handle
  tx_rx_item trx_item;

  // Count packets collected
  int num_item_col;

  virtual interface tx_rx_if vif;

  // component macro
  `uvm_component_utils_begin(tx_rx_monitor)
    `uvm_field_int(num_item_col, UVM_ALL_ON)
  `uvm_component_utils_end
  
  //Scoreboard port configuration
  uvm_analysis_port#(tx_rx_item) tx_rx_out;

  // component constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
	// Create Scoreboard interface
	tx_rx_out = new("tx_rx_out", this); 
  endfunction : new

  function void connect_phase(uvm_phase phase);
    if (!tx_rx_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: connect_phase

  // UVM run() phase
  task run_phase(uvm_phase phase);
	super.run_phase(phase);
	`uvm_info(get_full_name(), "tx_rx monitor", UVM_LOW);

	// Look for packets after reset
    @(posedge vif.reset)
   	@(negedge vif.reset)
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
    forever begin 
      // Create collected packet instance
      trx_item = tx_rx_item::type_id::create("trx_item", this);

      fork
        // collect packet
        vif.collect_packet(trx_item.data, trx_item.halt, trx_item.valid);
        // trigger transaction at start of packet
       // @(posedge vif.monstart) void'(begin_tr(trx_item, "Monitor_Tx_Rx_item"));
      join

      // End transaction recording
      //end_tr(trx_item);
	  //connect the interface to Scoreboard
		tx_rx_out.write(trx_item);
      `uvm_info(get_type_name(), $sformatf("Data Collected :\n%s", trx_item.sprint()), UVM_LOW)
      num_item_col++;
    end
  endtask : run_phase

  // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: Monitor Collected %0d tx_rx Packets", num_item_col), UVM_LOW)
  endfunction : report_phase

endclass : tx_rx_monitor
