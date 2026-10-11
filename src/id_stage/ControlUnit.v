
module ControlUnit(
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        mem_write,
    output reg [2:0]  alu_src,     
    output reg        alu_src_a,   
    output reg [1:0]  mem_to_reg,  
    output reg [3:0]  alu_ctrl,
    output reg        branch,
    output reg [1:0]  jump,        
    output reg        is_rtype_shift 
);


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


    localparam ALU_ADD   = 4'b0000;
    localparam ALU_SUB   = 4'b0001;
    localparam ALU_SLL   = 4'b0010;
    localparam ALU_SLT   = 4'b0011;
    localparam ALU_SLTU  = 4'b0100;
    localparam ALU_XOR   = 4'b0101;
    localparam ALU_SRL   = 4'b0110;
    localparam ALU_SRA   = 4'b0111;
    localparam ALU_OR    = 4'b1000;
    localparam ALU_AND   = 4'b1001;
    localparam ALU_PASS_B= 4'b1111;

    always @(*) begin
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        alu_src    = 3'b000;
        alu_src_a  = 1'b0;
        mem_to_reg = 2'b00;
        alu_ctrl   = ALU_ADD;
        branch     = 1'b0;
        jump       = 2'b00;
        is_rtype_shift = 1'b0;

        case (opcode)

            OP_ALU: begin
                reg_write = 1'b1;
                alu_src   = 3'b000;
                case (funct3)
                    F3_ADD: begin
                        if (funct7 == F7_0)      alu_ctrl = ALU_ADD;
                        else if (funct7 == F7_1) alu_ctrl = ALU_SUB;
                    end
                    F3_SLL: begin
                        alu_ctrl = ALU_SLL;
                        is_rtype_shift = 1'b1;
                    end
                    F3_SLT:  alu_ctrl = ALU_SLT;
                    F3_SLTU: alu_ctrl = ALU_SLTU;
                    F3_XOR:  alu_ctrl = ALU_XOR;
                    F3_SRL: begin
                        is_rtype_shift = 1'b1;
                        if (funct7 == F7_0)      alu_ctrl = ALU_SRL;
                        else if (funct7 == F7_1) alu_ctrl = ALU_SRA;
                    end
                    F3_OR:   alu_ctrl = ALU_OR;
                    F3_AND:  alu_ctrl = ALU_AND;
                endcase
            end


            OP_ALUI: begin
                reg_write = 1'b1;
                alu_src   = 3'b001;
                case (funct3)
                    F3_ADD:  alu_ctrl = ALU_ADD;
                    F3_SLL:  alu_ctrl = ALU_SLL;
                    F3_SLT:  alu_ctrl = ALU_SLT;
                    F3_SLTU: alu_ctrl = ALU_SLTU;
                    F3_XOR:  alu_ctrl = ALU_XOR;
                    F3_SRL: begin
                        if (funct7[5] == 1'b0) alu_ctrl = ALU_SRL;
                        else                    alu_ctrl = ALU_SRA;
                    end
                    F3_OR:   alu_ctrl = ALU_OR;
                    F3_AND:  alu_ctrl = ALU_AND;
                endcase
            end


            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 3'b001;
                mem_to_reg = 2'b01;
                alu_ctrl   = ALU_ADD;
            end


            OP_STORE: begin
                mem_write = 1'b1;
                alu_src   = 3'b010;
                alu_ctrl  = ALU_ADD;
            end


            OP_BRANCH: begin
                branch = 1'b1;
                alu_src = 3'b000;
            end


            OP_JAL: begin
                reg_write  = 1'b1;
                mem_to_reg = 2'b10;
                jump       = 2'b01;
            end


            OP_JALR: begin
                reg_write  = 1'b1;
                mem_to_reg = 2'b10;
                jump       = 2'b10;
                alu_src    = 3'b001;
                alu_ctrl   = ALU_ADD;
            end


            OP_LUI: begin
                reg_write  = 1'b1;
                alu_src    = 3'b011;
                alu_ctrl   = ALU_PASS_B;
            end


            OP_AUIPC: begin
                reg_write  = 1'b1;
                alu_src_a  = 1'b1;   
                alu_src    = 3'b011; 
                alu_ctrl   = ALU_ADD;
            end
        endcase
    end

endmodule
