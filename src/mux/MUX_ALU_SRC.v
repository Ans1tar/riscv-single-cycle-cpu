module MUX_ALU_SRC(
    input  wire [31:0] rs2_data,
    input  wire [31:0] imm_I,
    input  wire [31:0] imm_S,
    input  wire [31:0] imm_U,
    input  wire [31:0] pc,
    input  wire [2:0]  sel,
    output wire [31:0] out
);

    assign out = (sel == 3'b000) ? rs2_data :
                 (sel == 3'b001) ? imm_I :
                 (sel == 3'b010) ? imm_S :
                 (sel == 3'b011) ? imm_U :
                 (sel == 3'b100) ? pc :
                 32'd0;

endmodule
