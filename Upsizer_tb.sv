module test;
  localparam WIDTH = 32;
  localparam NUM_REG=2;

  /* Make a reset that pulses once. */
  reg reset = 1;
  initial begin
     # 5 reset = 0;
     # 50 reset = 1;
     # 1000 $stop;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #5 clk = !clk;

  reg s_axis_tvalid = 0;
  reg [WIDTH-1:0] s_axis_tdata = 100;
  reg s_axis_tlast = 0;
  reg m_axis_tready = 1;
  initial begin
    #100 s_axis_tvalid = 1;
  end

  wire s_axis_tready;
  wire m_axis_tvalid;
  wire [WIDTH*NUM_REG-1:0] m_axis_tdata;
  wire m_axis_tlast;
  my_axis_dwidth_upsize upsizer (.aclk(clk),                    // input wire aclk
    .aresetn(reset),              // input wire aresetn
    .s_axis_tvalid(s_axis_tvalid),  // input wire s_axis_tvalid
    .s_axis_tready(s_axis_tready),  // output wire s_axis_tready
    .s_axis_tdata(s_axis_tdata),    // input wire [31 : 0] s_axis_tdata
    .s_axis_tlast(s_axis_tlast),   

    .m_axis_tvalid(m_axis_tvalid),  // output wire m_axis_tvalid
    .m_axis_tready(m_axis_tready),  // input wire m_axis_tready
    .m_axis_tdata(m_axis_tdata),    // output wire [63 : 0] m_axis_tdata
    .m_axis_tlast(m_axis_tlast));

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);
    
    // $monitor("At time %t, value = %h (%0d)",
    //           $time, value, value);
  end
endmodule // test