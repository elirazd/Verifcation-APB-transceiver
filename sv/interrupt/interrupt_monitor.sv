/*-----------------------------------------------------------------
File name     : interrupt_monitor.sv
Developers    : Eliraz Deutsch
Description   : IRQ protocol monitor
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: interrupt_monitor
//
//------------------------------------------------------------------------------

class interrupt_monitor extends uvm_monitor;

	// Interface pointer:
	virtual interface interrupt_if vif;

	// Collected Data handle
 	interrupt_data pkt;

  	// Count packets collected
 	int num_pkt_col;

	// Analysis port:
	uvm_analysis_port#(interrupt_data) int_out;

	// component macro
	`uvm_component_utils_begin(interrupt_monitor)
		`uvm_field_int(num_pkt_col, UVM_ALL_ON)
	`uvm_component_utils_end


	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Analysis port constructor:
		int_out = new("int_out", this);
	endfunction

	virtual task run_phase(uvm_phase phase);

		super.run_phase(phase);

		`uvm_info(get_full_name(), "Interrupt monitor", UVM_LOW);

		// Look for packets after reset
    		@(posedge vif.reset)
   		@(negedge vif.reset)
    		`uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)

    		forever begin 

      			// Create collected packet instance
      			pkt = interrupt_data::type_id::create("pkt", this);

			fork
        		// collect packet
        		vif.collect_transaction(pkt.irq);
			//@(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_Interrupt_Packet"));
      			join
			//end_tr(pkt);

			// Write to the analysis port:
			int_out.write(pkt);

			if(pkt.irq ==1)
     				`uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
      			
			num_pkt_col++;
    		end

	endtask : run_phase


	function void connect_phase(uvm_phase phase);
		if (!interrupt_vif_config::get(this,get_full_name(),"vif", vif))
 		`uvm_error("NOVIF",{"virtual interface must be set for: ", get_full_name(), ".vif"})
	endfunction : connect_phase
	

	// UVM report_phase
  	function void report_phase(uvm_phase phase);
    		`uvm_info(get_type_name(), $sformatf("Report: Interrupt Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  	endfunction : report_phase

	

endclass : interrupt_monitor

