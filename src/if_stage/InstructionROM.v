

module InstructionROM(
    input  wire [7:0]  addr,
    output wire [31:0] instr
);

    reg [31:0] imem [0:255];


    function [31:0] R;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            R = {funct7, rs2, rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] I;
        input [11:0] imm;
        input [4:0]  rs1;
        input [2:0]  funct3;
        input [4:0]  rd;
        input [6:0]  opcode;
        begin
            I = {imm, rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] B;
        input [12:0] imm;
        input [4:0]  rs2;
        input [4:0]  rs1;
        input [2:0]  funct3;
        input [6:0]  opcode;
        begin
            B = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
        end
    endfunction

    function [31:0] U;
        input [19:0] imm;
        input [4:0]  rd;
        input [6:0]  opcode;
        begin
            U = {imm, rd, opcode};
        end
    endfunction

    function [31:0] J;
        input [20:0] imm;
        input [4:0]  rd;
        input [6:0]  opcode;
        begin
            J = {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
        end
    endfunction


    localparam OP_ALU   = 7'b0110011;
    localparam OP_ALUI  = 7'b0010011;
    localparam OP_LOAD  = 7'b0000011;
    localparam OP_STORE = 7'b0100011;
    localparam OP_BRANCH= 7'b1100011;
    localparam OP_JAL   = 7'b1101111;
    localparam OP_JALR  = 7'b1100111;
    localparam OP_LUI   = 7'b0110111;
    localparam OP_AUIPC = 7'b0010111;


    localparam F3_ADD  = 3'b000;
    localparam F3_SLL  = 3'b001;
    localparam F3_SLT  = 3'b010;
    localparam F3_SLTU = 3'b011;
    localparam F3_XOR  = 3'b100;
    localparam F3_SRL  = 3'b101;
    localparam F3_OR   = 3'b110;
    localparam F3_AND  = 3'b111;


    localparam F7_0 = 7'b0000000;
    localparam F7_1 = 7'b0100000;  

    integer idx;
    initial begin
        for (idx = 0; idx < 256; idx = idx + 1) imem[idx] = 32'b0;









        imem[0]  = I(12'd10, 5'd0,  F3_ADD, 5'd5,  OP_ALUI);

        imem[1]  = I(12'd0,  5'd0,  F3_ADD, 5'd6,  OP_ALUI);

        imem[2]  = I(12'd1,  5'd0,  F3_ADD, 5'd7,  OP_ALUI);

        imem[3]  = I(12'd1,  5'd0,  F3_ADD, 5'd8,  OP_ALUI);

        imem[4]  = I(12'd1,  5'd5,  F3_SLT, 5'd9,  OP_ALUI);

        imem[5]  = 32'h02049663;  

        imem[6]  = I(12'd2,  5'd5,  F3_SLT, 5'd9,  OP_ALUI);

        imem[7]  = 32'h02049463;  

        imem[8]  = R(F7_0, 5'd7, 5'd6, F3_ADD, 5'd9,  OP_ALU);

        imem[9]  = I(12'd0,  5'd7,  F3_ADD, 5'd6,  OP_ALUI);

        imem[10] = I(12'd0,  5'd9,  F3_ADD, 5'd7,  OP_ALUI);

        imem[11] = I(12'd1,  5'd8,  F3_ADD, 5'd8,  OP_ALUI);

        imem[12] = R(F7_0, 5'd5, 5'd8, F3_SLT, 5'd9,  OP_ALU);

        imem[13] = 32'hFE0496E3;  

        imem[14] = I(12'd0,  5'd7,  F3_ADD, 5'd10, OP_ALUI);

        imem[15] = J(21'd16, 5'd0,  OP_JAL);

        imem[16] = I(12'd0,  5'd0,  F3_ADD, 5'd10, OP_ALUI);

        imem[17] = J(21'd8,  5'd0,  OP_JAL);

        imem[18] = I(12'd1,  5'd0,  F3_ADD, 5'd10, OP_ALUI);

    end

    assign instr = imem[addr];

endmodule
