/*-----------------------------------------------------------------
File name     : interrupt_agent.sv
Developers    : Eliraz Deutsch
Description   : IRQ agent file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: interrupt_agent
//
//------------------------------------------------------------------------------

class interrupt_agent extends uvm_agent;

	interrupt_monitor	interrupt_mon;

	`uvm_component_utils(interrupt_agent)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		// Monitor constructor:
		interrupt_mon = interrupt_monitor::type_id::create("interrupt_mon", this);

	endfunction : build_phase

	virtual function void connect_phase(uvm_phase phase);
	endfunction

endclass
