/*-----------------------------------------------------------------
File name     : tx_rx_agent.sv
Developers    : Eliraz Deutsch
Description   : apb agent file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: tx_rx_agent
//
//------------------------------------------------------------------------------

class tx_rx_agent extends uvm_agent;

	// predeclared field inherited from uvm_agent determines whether an agent is active or passive.
   
	tx_rx_monitor   	monitor;
	tx_rx_sequencer 	sequencer;  
	tx_rx_driver    	driver;
	drv_type 			drv;
	
	// component macro
  `uvm_component_utils_begin(tx_rx_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
	`uvm_field_enum(drv_type, drv, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  	virtual function void set_drv(drv_type driver);
		drv = driver;
	endfunction 

  // UVM build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = tx_rx_monitor::type_id::create("monitor", this);
	`uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
    if(is_active == UVM_ACTIVE) begin
		`uvm_info(get_type_name(), {" ", get_full_name()}, UVM_LOW);
		sequencer = tx_rx_sequencer::type_id::create("sequencer", this);
		driver = tx_rx_driver::type_id::create("driver", this);
		driver.set_drv(drv);
	end
  endfunction : build_phase

  // UVM connect_phase
  function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) 
      // connect the driver to the sequencer 
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase

/*
  // Assign the virtual interfaces of the agent's children
  function void assign_vi(virtual interface tx_rx_if vif);
    rx_monitor.vif = vif;
	tx_monitor.vif = vif;
    if (is_active == UVM_ACTIVE) 
      m_driver.vif = vif;
	  s_driver.vif = vif;
  endfunction : assign_vi
*/

endclass : tx_rx_agent

