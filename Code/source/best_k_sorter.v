`timescale 1ns / 1ps

module top_k_sorter (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid_in,     // "done" signal from Distance Engine
    input  wire [17:0] new_dist,     // Distance from Distance Engine
    input  wire [1:0]  new_label,    // Class label (bits [1:0] from memory)
    
    // PACKED OUTPUT: 5 items * 20 bits = 100 bits total
    // Format: {18-bit Distance, 2-bit Class}
    // [19:0]   = Rank 1 (Best)
    // [39:20]  = Rank 2
    // [59:40]  = Rank 3
    // [79:60]  = Rank 4
    // [99:80]  = Rank 5
    output wire [99:0] sorted_list,
    output reg         finished
);

    // Max value (infinity) to initialize registers
    localparam MAX_DIST = 18'h3FFFF;

    // Internal Registers to hold the sorted values
    // We keep these separate to preserve your original shifting logic
    reg [17:0] dist_1, dist_2, dist_3, dist_4, dist_5;
    reg [1:0]  class_1, class_2, class_3, class_4, class_5;

    // --- SORTING LOGIC (Unchanged) ---
    always @(posedge clk) begin
        if (rst) begin
            finished <= 1'b0;
            dist_1 <= MAX_DIST; dist_2 <= MAX_DIST; dist_3 <= MAX_DIST; 
            dist_4 <= MAX_DIST; dist_5 <= MAX_DIST;
            class_1 <= 0; class_2 <= 0; class_3 <= 0; class_4 <= 0; class_5 <= 0;
        end
        else if (valid_in) begin
            finished <= 1'b0;
            // Insertion Sort: Find position and shift others down
            if (new_dist < dist_1) begin
                dist_1 <= new_dist; class_1 <= new_label;
                dist_2 <= dist_1;   class_2 <= class_1;
                dist_3 <= dist_2;   class_3 <= class_2;
                dist_4 <= dist_3;   class_4 <= class_3;
                dist_5 <= dist_4;   class_5 <= class_4;
            end
            else if (new_dist < dist_2) begin
                dist_2 <= new_dist; class_2 <= new_label;
                dist_3 <= dist_2;   class_3 <= class_2;
                dist_4 <= dist_3;   class_4 <= class_3;
                dist_5 <= dist_4;   class_5 <= class_4;
            end
            else if (new_dist < dist_3) begin
                dist_3 <= new_dist; class_3 <= new_label;
                dist_4 <= dist_3;   class_4 <= class_3;
                dist_5 <= dist_4;   class_5 <= class_4;
            end
            else if (new_dist < dist_4) begin
                dist_4 <= new_dist; class_4 <= new_label;
                dist_5 <= dist_4;   class_5 <= class_4;
            end
            else if (new_dist < dist_5) begin
                dist_5 <= new_dist; class_5 <= new_label;
            end
        end
        else begin
            finished <= 1'b1;
        end
    end

    // --- OUTPUT PACKING ---
    // Concatenate {Distance, Class} for each rank
    // Rank 1 is at the bottom (LSB) for easy indexing
    assign sorted_list[19:0]   = {dist_1, class_1};
    assign sorted_list[39:20]  = {dist_2, class_2};
    assign sorted_list[59:40]  = {dist_3, class_3};
    assign sorted_list[79:60]  = {dist_4, class_4};
    assign sorted_list[99:80]  = {dist_5, class_5};

endmodule