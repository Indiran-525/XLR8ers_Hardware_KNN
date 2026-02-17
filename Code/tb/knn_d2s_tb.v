`timescale 1ns / 1ps

module tb_distance_engine;

reg clk, rst, start;
reg signed [7:0] x_in, y_in;
reg signed [7:0] x_mem, y_mem;

wire [17:0] dist_out;
wire done;
wire sw = 1'b1;
knn_d2s UUT (.clk(clk), .rst(rst), .sw(sw));

// Clock
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;
    
    #10000;
    
    $finish;
end

endmodule
