/*-----------------------------------------------------------------
File name     : apb_driver.sv
Developers    : Eliraz Deutsch
Description   : apb driver file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: apb_driver
//
//------------------------------------------------------------------------------

// using type parameterized driver which defines built-in apb_packet handle req 
class apb_driver extends uvm_driver #(apb_packet);

  // Declare this property to count packets sent
  int num_sent;

  virtual interface apb_if vif;

  // component macro
  `uvm_component_utils_begin(apb_driver)
    `uvm_field_int(num_sent, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void connect_phase(uvm_phase phase);
    if (!apb_vif_config::get(this,"","vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: connect_phase

  // UVM run_phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
	fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // Gets packets from the sequencer and passes them to the driver. 
  task get_and_drive();
    @(posedge vif.reset);
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
    forever begin
      // Get new item from the sequencer
      seq_item_port.get_next_item(req);

      `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", req.sprint()), UVM_HIGH)
       
      fork
        // send packet
        begin
        vif.send_to_dut(req.addr, req.data, req.mode);
        end
        // trigger transaction at start of packet (trigger signal from interface)
        //@(posedge vif.drvstart) void'(begin_tr(req, "Driver_APB_Packet"));
      join

      // End transaction recording
      //end_tr(req);
      num_sent++;
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive
  
  // Reset all TX signals
  task reset_signals();
    forever 
     vif.reset_port();
  endtask : reset_signals

  // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: APB TX driver sent %0d packets", num_sent), UVM_LOW)
  endfunction : report_phase

endclass : apb_driver
