
module NextPC(
    input  wire [31:0] pc,
    input  wire [31:0] imm_I,
    input  wire [31:0] imm_B,
    input  wire [31:0] imm_J,
    input  wire [1:0]  jump,
    input  wire        branch,
    input  wire        branch_taken,
    input  wire [31:0] jalr_rs1,
    output wire [31:0] next_pc
);

    wire [31:0] pc_plus_4 = pc + 32'd4;
    wire [31:0] branch_target = pc + imm_B;
    wire [31:0] jal_target    = pc + imm_J;
    wire [31:0] jalr_target   = (jalr_rs1 + imm_I) & 32'hFFFFFFFE; 

    assign next_pc = (jump == 2'b01) ? jal_target :          
                     (jump == 2'b10) ? jalr_target :         
                     (branch && branch_taken) ? branch_target : 
                     pc_plus_4;                               

endmodule
