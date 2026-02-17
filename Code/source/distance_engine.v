module distance_engine_2d (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,

    input  wire [7:0] x_in,
    input  wire [7:0] y_in,

    input  wire [7:0] x_mem,
    input  wire [7:0] y_mem,

    output reg  [17:0] dist_out,
    output reg         done
);

reg signed [9:0] dx, dy;
reg [17:0] dx_sq, dy_sq;

always @(*) begin
    if(rst) begin
        done = 1'b0;
    end
    else begin
        done = 1'b0;
        dx = x_mem - x_in;
        dy = y_mem - y_in;
        dx_sq = dx * dx;
        dy_sq = dy * dy;
        dist_out = dx_sq + dy_sq;
        $display("distance - %d, x = %d, y = %d", dist_out, x_mem, y_mem);
        done = 1'b1;
    end
end

endmodule
