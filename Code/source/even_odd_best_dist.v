`timescale 1ns / 1ps

module final_merge_sort (
    input clk, rst, start,
    input  wire [99:0] packed_odd,  // 5 items from Odd Sorter
    input  wire [99:0] packed_even, // 5 items from Even Sorter
    output reg  [99:0] final_top5,   // The Absolute Best 5
    output reg done
);

    // Array to hold all 10 candidates for sorting
    // Format: {Distance[17:0], Class[1:0]}
    reg [19:0] candidates [0:9];
    reg [19:0] temp;
    integer i, j;

    always @(*) begin
        // ---------------------------------------------------------
        // 1. UNPACKING
        // ---------------------------------------------------------
        // Odd List (Indices 0-4)
        if(start) begin
        candidates[0] = packed_odd[19:0];
        candidates[1] = packed_odd[39:20];
        candidates[2] = packed_odd[59:40];
        candidates[3] = packed_odd[79:60];
        candidates[4] = packed_odd[99:80];

        // Even List (Indices 5-9)
        candidates[5] = packed_even[19:0];
        candidates[6] = packed_even[39:20];
        candidates[7] = packed_even[59:40];
        candidates[8] = packed_even[79:60];
        candidates[9] = packed_even[99:80];

        // ---------------------------------------------------------
        // 2. BUBBLE SORT (The "Thunderdome")
        // ---------------------------------------------------------
        // We compare every item against every other item.
        // Smallest distance bubbles to the top (Index 0).
        
        for (i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 9; j = j + 1) begin
                // Compare Distances (Upper 18 bits: [19:2])
                // If Item[j+1] is SMALLER (Better) than Item[j], swap them.
                if (candidates[j+1][19:2] < candidates[j][19:2]) begin
                    temp = candidates[j];
                    candidates[j] = candidates[j+1];
                    candidates[j+1] = temp;
                end
            end
        end

        // ---------------------------------------------------------
        // 3. PACKING THE WINNERS
        // ---------------------------------------------------------
        // Take the top 5 (Indices 0-4) and pack them into the output bus.
        
        final_top5[19:0]  = candidates[0]; // Best
        final_top5[39:20] = candidates[1];
        final_top5[59:40] = candidates[2];
        final_top5[79:60] = candidates[3];
        final_top5[99:80] = candidates[4]; // 5th Best

        done = 1'b1;
        $display("%d %d %d %d %d", candidates[0][1:0], candidates[1][1:0], candidates[2][1:0], candidates[3][1:0], candidates[4][1:0]);
        $display("%d %d %d %d %d", candidates[0][19:2], candidates[1][19:2], candidates[2][19:2], candidates[3][19:2], candidates[4][19:2]);
        end
    end

endmodule