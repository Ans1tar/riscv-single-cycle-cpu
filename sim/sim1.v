`timescale 1ns / 1ps


module sim1;
    reg clk;
    reg rst;
    integer failures;
    integer i;

    cpu_top uut (
        .clk(clk),
        .rst(rst),
        .fib_result(),
        .done()
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
    localparam F3_BEQ  = 3'b000;
    localparam F3_BNE  = 3'b001;
    localparam F3_BLT  = 3'b100;
    localparam F3_BGE  = 3'b101;
    localparam F3_BLTU = 3'b110;
    localparam F3_BGEU = 3'b111;
    localparam F3_LB   = 3'b000;
    localparam F3_LH   = 3'b001;
    localparam F3_LW   = 3'b010;
    localparam F3_LBU  = 3'b100;
    localparam F3_LHU  = 3'b101;
    localparam F3_SB   = 3'b000;
    localparam F3_SH   = 3'b001;
    localparam F3_SW   = 3'b010;

    localparam F7_0 = 7'b0000000;
    localparam F7_1 = 7'b0100000;

    function [31:0] R;
        input [6:0] f7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] f3;
        input [4:0] rd;
        input [6:0] op;
        begin R = {f7, rs2, rs1, f3, rd, op}; end
    endfunction

    function [31:0] I;
        input [11:0] imm;
        input [4:0]  rs1;
        input [2:0]  f3;
        input [4:0]  rd;
        input [6:0]  op;
        begin I = {imm, rs1, f3, rd, op}; end
    endfunction

    function [31:0] B;
        input [12:0] imm;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] f3;
        input [6:0] op;
        begin B = {imm[12], imm[10:5], rs2, rs1, f3, imm[4:1], imm[11], op}; end
    endfunction

    function [31:0] U;
        input [19:0] imm;
        input [4:0]  rd;
        input [6:0]  op;
        begin U = {imm, rd, op}; end
    endfunction

    function [31:0] J;
        input [20:0] imm;
        input [4:0]  rd;
        input [6:0]  op;
        begin J = {imm[20], imm[10:1], imm[11], imm[19:12], rd, op}; end
    endfunction

    function [31:0] S;
        input [11:0] imm;
        input [4:0]  rs2;
        input [4:0]  rs1;
        input [2:0]  f3;
        input [6:0]  op;
        begin S = {imm[11:5], rs2, rs1, f3, imm[4:0], op}; end
    endfunction

    task set_pc;
        input [31:0] val;
        begin
            force uut.pc_inst.pc = val;
        end
    endtask

    task tick;
        begin
            #1 clk = 1;
            #1 clk = 0;
        end
    endtask

    task check;
        input [31:0] actual;
        input [31:0] expected;
        input [8*40:1] msg;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s, got 0x%08h, expected 0x%08h", msg, actual, expected);
                failures = failures + 1;
            end else begin
                $display("PASS: %s", msg);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        failures = 0;

        force uut.pc_inst.pc = 32'd0;
        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        for (i = 0; i < 256; i = i + 1) uut.imem_inst.imem[i] = 32'd0;
        for (i = 0; i < 1024; i = i + 1) uut.dmem_inst.dmem[i] = 8'd0;

        #5 rst = 0;




        uut.regfile_inst.registers[1] = 32'd5;
        uut.regfile_inst.registers[2] = 32'd7;
        uut.imem_inst.imem[0] = R(F7_0, 5'd2, 5'd1, F3_ADD, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd12, "R-ADD");


        uut.regfile_inst.registers[1] = 32'd10;
        uut.regfile_inst.registers[2] = 32'd3;
        uut.imem_inst.imem[0] = R(F7_1, 5'd2, 5'd1, F3_ADD, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd7, "R-SUB");


        uut.regfile_inst.registers[1] = 32'd1;
        uut.regfile_inst.registers[2] = 32'd3;
        uut.imem_inst.imem[0] = R(F7_0, 5'd2, 5'd1, F3_SLL, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd8, "R-SLL");


        uut.regfile_inst.registers[1] = 32'hFFFFFFFF;
        uut.regfile_inst.registers[2] = 32'd1;
        uut.imem_inst.imem[0] = R(F7_0, 5'd2, 5'd1, F3_SLT, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd1, "R-SLT");


        uut.regfile_inst.registers[1] = 32'hFFFFFFFF;
        uut.regfile_inst.registers[2] = 32'd1;
        uut.imem_inst.imem[0] = R(F7_0, 5'd2, 5'd1, F3_SLTU, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd0, "R-SLTU");


        uut.regfile_inst.registers[1] = 32'd7;
        uut.regfile_inst.registers[2] = 32'd3;
        uut.imem_inst.imem[0] = R(F7_0, 5'd2, 5'd1, F3_XOR, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd4, "R-XOR");


        uut.regfile_inst.registers[1] = 32'd32;
        uut.regfile_inst.registers[2] = 32'd2;
        uut.imem_inst.imem[0] = R(F7_0, 5'd2, 5'd1, F3_SRL, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd8, "R-SRL");


        uut.regfile_inst.registers[1] = 32'hFFFFFFF0;
        uut.regfile_inst.registers[2] = 32'd2;
        uut.imem_inst.imem[0] = R(F7_1, 5'd2, 5'd1, F3_SRL, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'hFFFFFFFC, "R-SRA");


        uut.regfile_inst.registers[1] = 32'd4;
        uut.regfile_inst.registers[2] = 32'd1;
        uut.imem_inst.imem[0] = R(F7_0, 5'd2, 5'd1, F3_OR, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd5, "R-OR");


        uut.regfile_inst.registers[1] = 32'd7;
        uut.regfile_inst.registers[2] = 32'd5;
        uut.imem_inst.imem[0] = R(F7_0, 5'd2, 5'd1, F3_AND, 5'd3, OP_ALU);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd5, "R-AND");




        uut.regfile_inst.registers[1] = 32'd10;
        uut.imem_inst.imem[0] = I(12'd5, 5'd1, F3_ADD, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd15, "I-ADDI");


        uut.regfile_inst.registers[1] = 32'hFFFFFFFF; 
        uut.imem_inst.imem[0] = I(12'd0, 5'd1, F3_SLT, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd1, "I-SLTI");


        uut.regfile_inst.registers[1] = 32'hFFFFFFFF;
        uut.imem_inst.imem[0] = I(12'd1, 5'd1, F3_SLTU, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd0, "I-SLTIU");


        uut.regfile_inst.registers[1] = 32'd7;
        uut.imem_inst.imem[0] = I(12'd3, 5'd1, F3_XOR, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd4, "I-XORI");


        uut.regfile_inst.registers[1] = 32'd4;
        uut.imem_inst.imem[0] = I(12'd1, 5'd1, F3_OR, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd5, "I-ORI");


        uut.regfile_inst.registers[1] = 32'd7;
        uut.imem_inst.imem[0] = I(12'd5, 5'd1, F3_AND, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd5, "I-ANDI");


        uut.regfile_inst.registers[1] = 32'd1;
        uut.imem_inst.imem[0] = I(12'h003, 5'd1, F3_SLL, 5'd3, OP_ALUI); 
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd8, "I-SLLI");


        uut.regfile_inst.registers[1] = 32'd32;
        uut.imem_inst.imem[0] = I(12'h002, 5'd1, F3_SRL, 5'd3, OP_ALUI); 
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'd8, "I-SRLI");


        uut.regfile_inst.registers[1] = 32'hFFFFFFF0;
        uut.imem_inst.imem[0] = I(12'h402, 5'd1, F3_SRL, 5'd3, OP_ALUI); 
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'hFFFFFFFC, "I-SRAI");




        uut.dmem_inst.dmem[0]   = 8'hF0;
        uut.dmem_inst.dmem[1]   = 8'hF1;
        uut.dmem_inst.dmem[2]   = 8'hF2;
        uut.dmem_inst.dmem[3]   = 8'hF3;


        uut.regfile_inst.registers[1] = 32'd0;
        uut.imem_inst.imem[0] = I(12'd0, 5'd1, F3_LB, 5'd3, OP_LOAD);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'hFFFFFFF0, "L-LB");


        uut.regfile_inst.registers[1] = 32'd0;
        uut.imem_inst.imem[0] = I(12'd0, 5'd1, F3_LH, 5'd3, OP_LOAD);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'hFFFFF1F0, "L-LH");


        uut.regfile_inst.registers[1] = 32'd0;
        uut.imem_inst.imem[0] = I(12'd0, 5'd1, F3_LW, 5'd3, OP_LOAD);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'hF3F2F1F0, "L-LW");


        uut.regfile_inst.registers[1] = 32'd0;
        uut.imem_inst.imem[0] = I(12'd0, 5'd1, F3_LBU, 5'd3, OP_LOAD);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'h000000F0, "L-LBU");


        uut.regfile_inst.registers[1] = 32'd0;
        uut.imem_inst.imem[0] = I(12'd0, 5'd1, F3_LHU, 5'd3, OP_LOAD);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'h0000F1F0, "L-LHU");




        uut.regfile_inst.registers[1] = 32'd0;       
        uut.regfile_inst.registers[2] = 32'h000000AB; 
        uut.imem_inst.imem[0] = S(12'd0, 5'd2, 5'd1, F3_SB, OP_STORE);
        for (i = 0; i < 4; i = i + 1) uut.dmem_inst.dmem[i] = 8'd0;
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check({24'b0, uut.dmem_inst.dmem[0]}, 32'h000000AB, "S-SB");


        uut.regfile_inst.registers[1] = 32'd0;
        uut.regfile_inst.registers[2] = 32'hAABBCCDD;
        uut.imem_inst.imem[0] = S(12'd0, 5'd2, 5'd1, F3_SH, OP_STORE);
        for (i = 0; i < 4; i = i + 1) uut.dmem_inst.dmem[i] = 8'd0;
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check({16'b0, uut.dmem_inst.dmem[1], uut.dmem_inst.dmem[0]}, 32'h0000CCDD, "S-SH");


        uut.regfile_inst.registers[1] = 32'd0;
        uut.regfile_inst.registers[2] = 32'hAABBCCDD;
        uut.imem_inst.imem[0] = S(12'd0, 5'd2, 5'd1, F3_SW, OP_STORE);
        for (i = 0; i < 4; i = i + 1) uut.dmem_inst.dmem[i] = 8'd0;
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check({uut.dmem_inst.dmem[3], uut.dmem_inst.dmem[2], uut.dmem_inst.dmem[1], uut.dmem_inst.dmem[0]}, 32'hAABBCCDD, "S-SW");






        uut.regfile_inst.registers[1] = 32'd5;
        uut.regfile_inst.registers[2] = 32'd5;
        uut.imem_inst.imem[0] = B(13'd8, 5'd2, 5'd1, F3_BEQ, OP_BRANCH); 
        uut.imem_inst.imem[1] = I(12'd1, 5'd0, F3_ADD, 5'd3, OP_ALUI);  
        uut.imem_inst.imem[2] = I(12'd2, 5'd0, F3_ADD, 5'd3, OP_ALUI);  
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick; 
        tick; 
        check(uut.regfile_inst.registers[3], 32'd2, "B-BEQ-taken");


        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.regfile_inst.registers[1] = 32'd3;
        uut.regfile_inst.registers[2] = 32'd5;
        uut.imem_inst.imem[0] = B(13'd8, 5'd2, 5'd1, F3_BNE, OP_BRANCH);
        uut.imem_inst.imem[1] = I(12'd1, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        uut.imem_inst.imem[2] = I(12'd2, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        tick;
        check(uut.regfile_inst.registers[3], 32'd2, "B-BNE-taken");


        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.regfile_inst.registers[1] = 32'd2;
        uut.regfile_inst.registers[2] = 32'd5;
        uut.imem_inst.imem[0] = B(13'd8, 5'd2, 5'd1, F3_BLT, OP_BRANCH);
        uut.imem_inst.imem[1] = I(12'd1, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        uut.imem_inst.imem[2] = I(12'd2, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        tick;
        check(uut.regfile_inst.registers[3], 32'd2, "B-BLT-taken");


        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.regfile_inst.registers[1] = 32'd5;
        uut.regfile_inst.registers[2] = 32'd2;
        uut.imem_inst.imem[0] = B(13'd8, 5'd2, 5'd1, F3_BGE, OP_BRANCH);
        uut.imem_inst.imem[1] = I(12'd1, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        uut.imem_inst.imem[2] = I(12'd2, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        tick;
        check(uut.regfile_inst.registers[3], 32'd2, "B-BGE-taken");


        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.regfile_inst.registers[1] = 32'd2;
        uut.regfile_inst.registers[2] = 32'd5;
        uut.imem_inst.imem[0] = B(13'd8, 5'd2, 5'd1, F3_BLTU, OP_BRANCH);
        uut.imem_inst.imem[1] = I(12'd1, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        uut.imem_inst.imem[2] = I(12'd2, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        tick;
        check(uut.regfile_inst.registers[3], 32'd2, "B-BLTU-taken");


        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.regfile_inst.registers[1] = 32'd5;
        uut.regfile_inst.registers[2] = 32'd2;
        uut.imem_inst.imem[0] = B(13'd8, 5'd2, 5'd1, F3_BGEU, OP_BRANCH);
        uut.imem_inst.imem[1] = I(12'd1, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        uut.imem_inst.imem[2] = I(12'd2, 5'd0, F3_ADD, 5'd3, OP_ALUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        tick;
        check(uut.regfile_inst.registers[3], 32'd2, "B-BGEU-taken");




        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.imem_inst.imem[0] = U(20'hA5A5A, 5'd3, OP_LUI);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'hA5A5A000, "U-LUI");


        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.imem_inst.imem[0] = U(20'h00001, 5'd3, OP_AUIPC);
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick;
        check(uut.regfile_inst.registers[3], 32'h00001000, "U-AUIPC");




        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.imem_inst.imem[0] = J(21'd8, 5'd3, OP_JAL);  
        uut.imem_inst.imem[1] = I(12'd1, 5'd0, F3_ADD, 5'd4, OP_ALUI); 
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick; 
        check(uut.regfile_inst.registers[3], 32'd4, "J-JAL-ret");  
        tick; 
        check(uut.regfile_inst.registers[4], 32'd2, "J-JAL-target"); 


        for (i = 0; i < 32; i = i + 1) uut.regfile_inst.registers[i] = 32'd0;
        uut.regfile_inst.registers[1] = 32'd0;      
        uut.imem_inst.imem[0] = I(12'd8, 5'd1, F3_ADD, 5'd3, OP_JALR); 
        uut.imem_inst.imem[2] = I(12'd9, 5'd0, F3_ADD, 5'd4, OP_ALUI); 
        set_pc(32'd0); #1; release uut.pc_inst.pc; tick; 
        check(uut.regfile_inst.registers[3], 32'd4, "J-JALR-ret");   
        tick; 
        check(uut.regfile_inst.registers[4], 32'd9, "J-JALR-target"); 


        $display("");
        $display("========================================");
        if (failures == 0) begin
            $display("ALL 37 RV32I TESTS PASSED!");
        end else begin
            $display("FAILED: %0d tests failed out of 37", failures);
        end
        $display("========================================");
        $finish;
    end

    always #1 clk = ~clk;

endmodule
