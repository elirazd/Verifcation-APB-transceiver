/*-----------------------------------------------------------------
File name     : transciver_scoreboard.sv
Developers    : Eliraz Deutsch
Description   : Transciver scoreboard file
Notes         : 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: transciver_scoreboard
//
//------------------------------------------------------------------------------
class transciver_scoreboard extends uvm_scoreboard;

   // TLM Port Declarations
   `uvm_analysis_imp_decl(_apb)
   `uvm_analysis_imp_decl(_tx)
   `uvm_analysis_imp_decl(_rx)
   `uvm_analysis_imp_decl(_irq)
   
   uvm_analysis_imp_apb  #(apb_packet, transciver_scoreboard) sb_apb;
   uvm_analysis_imp_tx #(tx_rx_item, transciver_scoreboard) sb_tx;
   uvm_analysis_imp_rx #(tx_rx_item, transciver_scoreboard) sb_rx;
   uvm_analysis_imp_irq #(interrupt_data, transciver_scoreboard) sb_irq;

   
   // Scoreboard Packet Queues
   bit[31:0] 	tx_queue[$];
   bit[31:0] 	rx_queue[$];

   
   // Scoreboard Statistics
   bit tx_full, rx_full;
   int tx_fill_level, rx_fill_level;
   
   `uvm_component_utils(transciver_scoreboard)

   // Constructor
	function new(string name="", uvm_component parent=null);
		super.new(name, parent);
		sb_apb = new("sb_apb", this);
		sb_tx = new("sb_tx", this);
		sb_rx = new("sb_rx", this);
		sb_irq = new("sb_irq", this);
	endfunction
      

	virtual function void write_apb(input apb_packet packet);
     
		bit[31:0] data_buff;
		`uvm_info(get_type_name(), $sformatf("New APB Packet\n details:%s",packet.sprint()), UVM_HIGH)
		// Make a copy for storing in the scoreboard
		// WRITE mode:
		if(packet.mode == WRITE) begin
			tx_queue.push_back(packet.data);

			tx_fill_level++;
			tx_full = (tx_fill_level>=8)?1:0;

			if(tx_full)
			`uvm_info(get_name(), "TX fifo is full", UVM_LOW)
		end

		// READ mode:
		else if(packet.mode == READ) begin
			data_buff = rx_queue.pop_front();

			rx_fill_level--;
			rx_full = (rx_fill_level>=8)?1:0;

			if(rx_full)
			`uvm_info(get_name(), "RX fifo is full", UVM_LOW)

			if(data_buff !== packet.data)
			`uvm_error(get_name(), $sformatf("ERROR for READ - expected:%0h actual:%0h", data_buff, packet.data))
		end
    endfunction
    
  // Channel APB write Packet Check implementationsb_packet
	virtual function void write_rx(input tx_rx_item rx);
		// Check rx_halt - should be set if RX fifo is full:
		if(rx.halt == 1 && rx_fill_level <8)
			`uvm_error(get_name(), $sformatf("RX halt set - RX fill level:%0d", rx_fill_level))
		if(rx.halt == 0 && rx_fill_level>=8)
			`uvm_error(get_name(), $sformatf("RX halt clear - RX fill level:%0d", rx_fill_level))

		// Check data validity:
		if(rx.valid)
		`uvm_info(get_name(), $sformatf("Get new item for RX:%s",rx.sprint()), UVM_HIGH)

		// Get RX transaction:
		if(rx.valid) begin
			rx_queue.push_back(rx.data);
			rx_fill_level++;
			rx_full = (rx_fill_level>=8)?1:0;

			if(rx_full)
			`uvm_info(get_name(), "RX fifo full", UVM_LOW)
		end 
	endfunction
    
  // Channel APB read Packet Check implementation
    virtual function void write_tx(input tx_rx_item tx);
		bit[31:0] data_buff_tx;

		if(tx.valid)
		`uvm_info(get_name(), $sformatf("Get new item for TX:%s",tx.sprint()), UVM_HIGH)

		// Send TX transaction:
		if(tx.valid) begin
			data_buff_tx = tx_queue.pop_front();
			tx_fill_level--;
			tx_full = (tx_fill_level>=8)?1:0;

			if(tx_full)
			`uvm_info(get_name(), "TX fifo full", UVM_LOW)

			if(data_buff_tx !== tx.data)
			`uvm_error(get_name(), $sformatf("ERROR for WRITE - expected:%0h actual:%0h", data_buff_tx, tx.data))
		end
	endfunction


	virtual function void write_irq (input interrupt_data int_trans);

		if(int_trans.irq)
		`uvm_info(get_name(), $sformatf("Get new transation for INT:%s",int_trans.sprint()), UVM_FULL)
	
		// Two conditions for int is set:
		// 1) TX fifo full 
		// 2) RX fifo empty

		if(int_trans.irq == 1) begin
			if(rx_fill_level != 0 && tx_fill_level<8)
			`uvm_error(get_name(), "The interrupt is set without any valid reason")
		end
   endfunction

// UVM check_phase
	function void check_phase(uvm_phase phase);
		super.check_phase(phase);

		// Check if the FIFOS are empty at the end of the simulation:
		if(rx_fill_level != 0)
		`uvm_error(get_name(), $sformatf("RX fifo is not empty at the end of the simulation : %0d", rx_fill_level))
		if(tx_fill_level != 0)
		`uvm_error(get_name(), $sformatf("TX fifo is not empty at the end of the simulation : %0d", tx_fill_level))
		if(rx_fill_level == 0 && tx_fill_level == 0)
		`uvm_info(get_name(), "Test finished sucessfully", UVM_LOW)
	endfunction : check_phase


endclass : transciver_scoreboard
       
