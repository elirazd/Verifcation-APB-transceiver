
`timescale 1ns/1ps
module apb_transceiver
(
 // APB bus bus interface
 input             pclk,
 input             presetn,
 input             psel,
 input             penable,
 input             pwrite, 
 input  [3:0]      paddr,
 input  [31:0]     pwdata,
 output reg [31:0] prdata,
 // Transmit
 output reg [31:0] tx_data,
 output            tx_valid,
 input             tx_halt,
// output            tx_full,
 // Receive
 input  [31:0]     rx_data,
 input             rx_valid,
 output            rx_halt,
// output            rx_full,
 // IRQ
 output            irq
 );

  parameter FIFO_DP = 8;

  wire             tx_fifo_full;
  wire             tx_fifo_empty;
  reg  [29:0]      tx_fifo_entries;
  wire             rx_fifo_full;
  wire             rx_fifo_empty;
  reg  [29:0]      rx_fifo_entries;
  wire             tx_push;
  wire             rx_push;
  wire             tx_pop;
  reg              rx_pop;


  // -------------------------------------------
  // -- Address decode
  // -------------------------------------------
  wire wr_en  = psel &  penable &  pwrite;
  wire rd_en  = psel & (!penable) & (!pwrite);

  // Tx Status Register Decode - Read Only
  wire tx_status_wren = 0;
  wire tx_status_rden = rd_en & paddr[3:2]==2'h0; // 0x0
  // Rx Status REgister Decode - Read Only
  wire rx_status_wren = 0;
  wire rx_status_rden = rd_en & paddr[3:2]==2'h1; // 0x4
  // Data Register Decode - Read/Write
  wire data_wren = 0;
  wire data_rden = rd_en & paddr[3:2]==2'h2;
  // Interrupt Register - RW1c
  wire irq_wren = wr_en & paddr[3:2]==2'h3;       // 0xc
  wire irq_rden = rd_en & paddr[3:2]==2'h3;

  // -------------------------------------------
  // -- Tx Status register
  // -------------------------------------------
  reg [31:0] r_tx_status;

  // initial force tx_data =0;
  always @(posedge pclk or negedge presetn)
  begin
    if(presetn == 1'b0)
      r_tx_status <= 32'b0;
    else
    begin
      r_tx_status[0]     <= ~tx_fifo_empty;
      r_tx_status[1]     <= tx_fifo_full;
      r_tx_status[31:2]  <= tx_fifo_entries;
    end
  end
  
  // -------------------------------------------
  // -- Rx Status register
  // -------------------------------------------
  reg [31:0] r_rx_status;
  always @(posedge pclk or negedge presetn)
  begin
    if(presetn == 1'b0)
      r_rx_status <= 32'b0;
    else
    begin
      r_rx_status[0]     <= ~rx_fifo_empty;
      r_rx_status[1]     <= rx_fifo_full;
      r_rx_status[31:2]  <= rx_fifo_entries;
    end
  end
  
  // -------------------------------------------
  // -- IRQ register
  // -------------------------------------------
  reg [31:0] r_irq;
  always @(posedge pclk or negedge presetn)
  begin
    if(presetn == 1'b0)
      r_irq <= 32'b0;
    else
    begin
      // Rx underflow
      if(data_rden & rx_fifo_empty)
        r_irq[0] <= 1'b1;
      else if(irq_wren & pwdata[0])
        r_irq[0] <= 1'b0;
      // Tx overflow
      if(data_wren & tx_fifo_full & ~tx_pop)
        r_irq[1] <= 1'b1;
      else if(irq_wren & pwdata[1])
        r_irq[1] <= 1'b0;
    end
  end
  assign irq = |r_irq;

  // -------------------------------------------
  // -- Tx fifo
  // -------------------------------------------
  reg [31:0] tx_fifo[$];
  assign tx_push = data_wren & (~tx_fifo_full |  (tx_fifo_full & tx_pop));

  reg tx_push_d;
  reg [31:0] pwdata_d;
  always @(posedge pclk or negedge presetn)
  begin
    if(presetn == 1'b0) begin
      tx_fifo.delete();
      tx_fifo_entries <= 30'b0;
      tx_push_d <= 0;
      pwdata_d <= 0;
    end else begin
      tx_push_d <= tx_push;
      pwdata_d  <= pwdata;
      if(tx_push_d) begin
        tx_fifo.push_back(pwdata_d);
      end
      if(tx_pop) begin
        tx_fifo.pop_front();
      end
      if(tx_push_d & ~tx_pop) begin
        tx_fifo_entries <= tx_fifo_entries+1;
      end
      if(tx_pop & ~tx_push_d) begin
        tx_fifo_entries <= tx_fifo_entries-1;
      end
    end
  end
  
  assign tx_fifo_empty   = (tx_fifo_entries == 0) ? 1'b1 : 1'b0;
  assign tx_fifo_full    = (tx_fifo_entries == FIFO_DP) ? 1'b1 : 1'b0;
  assign tx_valid        = ~tx_fifo_empty;
  assign tx_pop          = (~tx_halt & tx_valid);
//  assign tx_full         = tx_fifo_full;

  always @(tx_push_d or tx_pop) begin
    if(tx_fifo_empty)
      tx_data = 32'b0;
    else
      tx_data = tx_fifo[1];
  end

  // -------------------------------------------
  // -- Rx fifo
  // -------------------------------------------
  reg [31:0] rx_fifo[$];
  assign rx_push = rx_valid & ~rx_halt;
  always @(posedge pclk or negedge presetn)
  begin
    if(presetn == 1'b0) begin
      rx_fifo.delete();
      rx_fifo_entries <= 30'b0;
    end else
    begin
      if(rx_push) begin
        rx_fifo.push_back(rx_data);
      end
      if(rx_pop) begin
        rx_fifo.pop_front();
      end
      if(rx_push & ~rx_pop) begin
        rx_fifo_entries <= rx_fifo_entries+1;
      end
      if(rx_pop & ~rx_push) begin
        rx_fifo_entries <= rx_fifo_entries-1;
      end
    end
  end
  always @(posedge pclk or negedge presetn)
  begin
    if(presetn == 1'b0)
      rx_pop <= 1'b0;
    else
    begin
      if(data_rden && rx_fifo_empty == 0)
        rx_pop <= 1'b1;
      else
        rx_pop <= 1'b0;
    end
  end
  assign rx_fifo_empty   = (rx_fifo_entries == 0) ? 1'b1 : 1'b0;
  assign rx_fifo_full    = (rx_fifo_entries == FIFO_DP) ? 1'b1 : 1'b0;
  assign rx_halt         = rx_fifo_full;
//  assign rx_full         = rx_fifo_full;

  // --------------------------------------------
  // -- APB read data.
  // --------------------------------------------
  always @(posedge pclk or negedge presetn)
  begin
    if(presetn == 1'b0) begin
      prdata <= 32'b0;
    end else begin
      if(rd_en)
      begin
        case(paddr[3:0])
          4'h0 : prdata <= r_tx_status;
          4'h4 : prdata <= r_rx_status;
          4'h8 : prdata <= (rx_fifo_empty) ? 32'b0 : rx_fifo[0];
          4'hc : prdata <= r_irq;
          default : prdata <= 32'b0;
        endcase
      end else begin
        prdata <= 32'b0;
      end
    end
  end
   
endmodule



