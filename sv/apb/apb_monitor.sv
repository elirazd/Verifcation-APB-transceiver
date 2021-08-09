/*-----------------------------------------------------------------
File name     : apb_monitor.sv
Developers    : Eliraz Deutsch
Description   : APB protocol monitor
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: apb_monitor
//
//------------------------------------------------------------------------------

class apb_monitor extends uvm_monitor;

  // Collected Data handle
  apb_packet pkt;

  // Count packets collected
  int num_pkt_col;
  
  //Interface pointer
  virtual interface apb_if vif;
  
  //Scoreboard port configuration  
  uvm_analysis_port#(apb_packet) apb_out;

  // component macro
  `uvm_component_utils_begin(apb_monitor)
    `uvm_field_int(num_pkt_col, UVM_ALL_ON)
  `uvm_component_utils_end

  // component constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
	// Create Scoreboard interface
	apb_out = new("apb_out", this);  
  endfunction : new

 function void connect_phase(uvm_phase phase);
    if (!apb_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: connect_phase

  // UVM run() phase
  task run_phase(uvm_phase phase);
	super.run_phase(phase);
    // Look for packets after reset
    @(posedge vif.reset)
    @(negedge vif.reset)
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
    forever begin 
      // Create collected packet instance
      pkt = apb_packet::type_id::create("pkt", this);

      fork
        // collect packet
        vif.collect_packet(pkt.addr, pkt.data, pkt.mode);
        // trigger transaction at start of packet
        //@(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_APB_Packet"));
      join
      //connect the interface to Scoreboard
	  apb_out.write(pkt);
	  //end_tr(pkt);
      `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
      num_pkt_col++;
    end
  endtask : run_phase

  // UVM report_phase
  function void report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("Report: APB Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  endfunction : report_phase

endclass : apb_monitor
