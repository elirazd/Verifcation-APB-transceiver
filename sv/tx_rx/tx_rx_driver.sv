/*-----------------------------------------------------------------
File name     : tx_rx_driver.sv
Developers    : Eliraz Deutsch
Description   : tx driver under tx_rx_agent
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: tx_rx_driver
//
//------------------------------------------------------------------------------


class tx_rx_driver extends uvm_driver #(tx_rx_item);

	// Declare this property to count packets sent
	int num_sent;

	virtual interface tx_rx_if vif;

		drv_type drv;

	// component macro
	`uvm_component_utils_begin(tx_rx_driver)
		`uvm_field_int(num_sent, UVM_ALL_ON)
		`uvm_field_enum(drv_type, drv, UVM_ALL_ON)
	`uvm_component_utils_end

	// Constructor - required syntax for UVM automation and utilities
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// Set agent mode function:
	virtual function void set_drv(drv_type driver);
		drv = driver;
	endfunction 

  function void connect_phase(uvm_phase phase);
    if (!tx_rx_vif_config::get(this,"","vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: connect_phase

  // UVM run_phase
  task run_phase(uvm_phase phase);	
  `uvm_info(get_type_name(), "in the driver", UVM_MEDIUM)
    fork
      reset_signals();
	  get_and_drive();
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
      `uvm_info(get_type_name(), $sformatf("Sending Item :\n%s", req.sprint()), UVM_LOW)
      fork
        // send packet
        begin
			send_to_dut(req);
        end
        // trigger transaction at start of packet (trigger signal from interface)
        //@(posedge vif.drvstart) void'(begin_tr(req, "Driver_tx_rx_Item"));
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
		@(posedge vif.reset);
		
		if (drv == MASTER)
			begin
			vif.data  <= 32'b0;
			vif.valid <= 1'b0;
			end
		else if(drv == SLAVE) begin
			vif.halt  <= 1'b0;	
			end 
	endtask : reset_signals
	
	virtual task send_to_dut(tx_rx_item req);

		@(posedge vif.clock)

		// trigger for transaction recording
    		vif.drvstart = 1'b1;

		if (vif.halt ==0 && drv == MASTER)
		begin
			vif.data <= req.data;
			vif.valid <= 1'b1;
			@(posedge vif.clock)
			vif.valid <= 1'b0;
		end
		else if (drv == SLAVE)
			vif.halt <= req.halt;

		// reset trigger
    		vif.drvstart = 1'b0;
	endtask

  // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: tx_rx_driver sent %0d items", num_sent), UVM_LOW)
  endfunction : report_phase

endclass : tx_rx_driver
