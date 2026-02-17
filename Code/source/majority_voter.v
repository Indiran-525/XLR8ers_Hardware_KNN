module majority_voter (
    input clk,rst,
    input  wire        start,        // "Valid" signal from the Sorter
    input  wire [99:0] sorted_list,  // Packed Input: 5 items * 20 bits
    input  wire        mode,         // 0 = K(3), 1 = K(5)
    
    output reg [1:0]   predicted_class,
    output reg         done
);

    // --- 1. UNPACKING ---
    // We extract ONLY the class bits (LSB [1:0]) from each 20-bit rank.
    // Rank 1 (Best) starts at bit 0.
    wire [1:0] class_1 = sorted_list[1:0];   // From Rank 1
    wire [1:0] class_2 = sorted_list[21:20]; // From Rank 2
    wire [1:0] class_3 = sorted_list[41:40]; // From Rank 3
    wire [1:0] class_4 = sorted_list[61:60]; // From Rank 4
    wire [1:0] class_5 = sorted_list[81:80]; // From Rank 5

    // Vote counters
    reg [2:0] votes_0, votes_1, votes_2, votes_3;

    always @(*) begin
        // Default State
        done = 1'b0;
        votes_0 = 0; votes_1 = 0; votes_2 = 0; votes_3 = 0;
        
        // Use the default winner (Rank 1) to prevent latches
        predicted_class = class_1; 

        if (start) begin
            // 2. Tally Votes for Top 3 (Always Active)
            case (class_1) 2'd0: votes_0 = votes_0 + 1; 2'd1: votes_1 = votes_1 + 1; 2'd2: votes_2 = votes_2 + 1; 2'd3: votes_3 = votes_3 + 1; endcase
            case (class_2) 2'd0: votes_0 = votes_0 + 1; 2'd1: votes_1 = votes_1 + 1; 2'd2: votes_2 = votes_2 + 1; 2'd3: votes_3 = votes_3 + 1; endcase
            case (class_3) 2'd0: votes_0 = votes_0 + 1; 2'd1: votes_1 = votes_1 + 1; 2'd2: votes_2 = votes_2 + 1; 2'd3: votes_3 = votes_3 + 1; endcase

            // 3. Tally Votes for Neighbors 4 & 5 (Only if Mode == 1)
            if (mode) begin
                case (class_4) 2'd0: votes_0 = votes_0 + 1; 2'd1: votes_1 = votes_1 + 1; 2'd2: votes_2 = votes_2 + 1; 2'd3: votes_3 = votes_3 + 1; endcase
                case (class_5) 2'd0: votes_0 = votes_0 + 1; 2'd1: votes_1 = votes_1 + 1; 2'd2: votes_2 = votes_2 + 1; 2'd3: votes_3 = votes_3 + 1; endcase
            end

            // 4. Determine Winner with "Closest Wins Tie" Logic
            
            // OVERRIDE:
            // Only switch the winner if a class has strictly MORE votes than ALL others.
            if (votes_0 > votes_1 && votes_0 > votes_2 && votes_0 > votes_3)
                predicted_class = 2'd0;
            else if (votes_1 > votes_0 && votes_1 > votes_2 && votes_1 > votes_3)
                predicted_class = 2'd1;
            else if (votes_2 > votes_0 && votes_2 > votes_1 && votes_2 > votes_3)
                predicted_class = 2'd2;
            else if (votes_3 > votes_0 && votes_3 > votes_1 && votes_3 > votes_2)
                predicted_class = 2'd3;
            
            // Output Valid
            done = 1'b1;
            $display("Class_in - %d",predicted_class);
        end
    end

endmodule