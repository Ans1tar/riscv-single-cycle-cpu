
module BranchCond(
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    output wire        branch_taken
);

    localparam OP_BRANCH = 7'b1100011;


    localparam F3_BEQ  = 3'b000;
    localparam F3_BNE  = 3'b001;
    localparam F3_BLT  = 3'b100;
    localparam F3_BGE  = 3'b101;
    localparam F3_BLTU = 3'b110;
    localparam F3_BGEU = 3'b111;

    reg taken;
    always @(*) begin
        if (opcode == OP_BRANCH) begin
            case (funct3)
                F3_BEQ:  taken = (rs1_data == rs2_data);
                F3_BNE:  taken = (rs1_data != rs2_data);
                F3_BLT:  taken = ($signed(rs1_data) < $signed(rs2_data));
                F3_BGE:  taken = ($signed(rs1_data) >= $signed(rs2_data));
                F3_BLTU: taken = (rs1_data < rs2_data);
                F3_BGEU: taken = (rs1_data >= rs2_data);
                default: taken = 1'b0;
            endcase
        end else begin
            taken = 1'b0;
        end
    end

    assign branch_taken = taken;

endmodule
