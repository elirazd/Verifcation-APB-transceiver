/*-----------------------------------------------------------------
File name     : hw_top.sv
Developers    : Eliraz Deutsch
Description   : hw_top file
Notes         : 
-----------------------------------------------------------------*/

module hw_top;

  // Clock and reset signals
  logic         clock;
  logic         reset;

  // Interfaces to the DUT
  apb_if apb(clock, reset);
  tx_rx_if tx(clock, reset);
  tx_rx_if rx(clock, reset);
  interrupt_if int_if(clock, reset);


  apb_transceiver dut(
    .pclk(clock),
    .presetn(~reset),
    // APB interface signals connection
    .psel(apb.psel),
    .penable(apb.penable),
    .pwrite(apb.pwrite),
  	.paddr(apb.paddr),
	.pwdata(apb.pwdata),
    .prdata(apb.prdata),
    // tx_rx interface signals connection
    //Transmit 
    .tx_data(rx.data),
    .tx_valid(rx.valid),
    .tx_halt(rx.halt),
    //recive   
    .rx_data(tx.data),
    .rx_valid(tx.valid),
    .rx_halt(tx.halt),

    //IRQ   
    .irq(int_if.irq));  
  always begin
    #5 clock = ~clock;
  end

  initial begin
    clock <= 0;
    reset <= 1'b0;
    @(negedge clock)
      #1 reset <= 1'b1;
    @(negedge clock)
      #1 reset <= 1'b0;
  end

endmodule
