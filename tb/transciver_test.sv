/*-----------------------------------------------------------------
File name     : transciver_test.sv
Developers    : Eliraz Deutsch
Description   : transciver tests list file
Notes         : 
-----------------------------------------------------------------*/

/*-----------------------------------------------------------------
 
	base_test class
 
 -----------------------------------------------------------------*/
class base_test extends uvm_test;

  // component macro
  `uvm_component_utils(base_test)

  // Components of the environment
  transciver_tb tb;

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase()
  virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
    tb = transciver_tb::type_id::create("tb",this);
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

endclass : base_test

/*-----------------------------------------------------------------
 
	default_test class
 
 -----------------------------------------------------------------*/
class default_test extends base_test;

  // component macro
  `uvm_component_utils(default_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase()
  virtual function void build_phase(uvm_phase phase);
	
	super.build_phase(phase);
	uvm_config_wrapper::set(this, "tb.mcsequencer.run_phase", "default_sequence", transciver_mcseqs::get_type());
  endfunction : build_phase
 
endclass : base_test