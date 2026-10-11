

module cpu_top(
    input  wire        clk,
    input  wire        rst,
    output reg  [31:0] fib_result,
    output reg         done
);


    wire [31:0] pc, next_pc, pc_plus_4;
    wire [31:0] instr;
    wire [6:0]  opcode;
    wire [4:0]  rs1, rs2, rd;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [4:0]  shamt;
    wire [31:0] imm_I, imm_S, imm_B, imm_U, imm_J;
    wire [31:0] rs1_data, rs2_data;
    wire        reg_write, mem_write;
    wire [2:0]  alu_src;
    wire        alu_src_a;
    wire [1:0]  mem_to_reg;
    wire [3:0]  alu_ctrl;
    wire        branch;
    wire [1:0]  jump;
    wire        branch_taken;
    wire [31:0] alu_src2;
    wire [31:0] alu_out;
    wire [31:0] mem_read_data;
    wire [31:0] wb_data;
    wire        is_rtype_shift;



    PC pc_inst (
        .clk(clk),
        .rst(rst),
        .en(!done),
        .next_pc(next_pc),
        .pc(pc)
    );

    InstructionROM imem_inst (
        .addr(pc[9:2]),
        .instr(instr)
    );

    ID id_inst (
        .instr(instr),
        .pc(pc),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .shamt(shamt),
        .imm_I(imm_I),
        .imm_S(imm_S),
        .imm_B(imm_B),
        .imm_U(imm_U),
        .imm_J(imm_J)
    );

    RegisterFile regfile_inst (
        .clk(clk),
        .rst(rst),
        .write_en(reg_write),
        .write_addr(rd),
        .write_data(wb_data),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    ControlUnit cu_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .alu_src_a(alu_src_a),
        .mem_to_reg(mem_to_reg),
        .alu_ctrl(alu_ctrl),
        .branch(branch),
        .jump(jump),
        .is_rtype_shift(is_rtype_shift)
    );

    MUX_ALU_SRC alu_src_mux (
        .rs2_data(rs2_data),
        .imm_I(imm_I),
        .imm_S(imm_S),
        .imm_U(imm_U),
        .pc(pc),
        .sel(alu_src),
        .out(alu_src2)
    );


    wire [31:0] alu_src1 = alu_src_a ? pc : rs1_data;

    ALU alu_inst (
        .a(alu_src1),
        .b(alu_src2),
        .shamt(shamt),
        .alu_ctrl(alu_ctrl),
        .is_rtype_shift(is_rtype_shift),
        .result(alu_out),
        .zero(),
        .lt_signed(),
        .lt_unsigned()
    );

    BranchCond branch_cond_inst (
        .opcode(opcode),
        .funct3(funct3),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .branch_taken(branch_taken)
    );

    DataRAM dmem_inst (
        .clk(clk),
        .addr(alu_out),
        .write_en(mem_write),
        .opcode(opcode),
        .funct3(funct3),
        .store_data(rs2_data),
        .read_data(mem_read_data)
    );

    NextPC next_pc_inst (
        .pc(pc),
        .imm_I(imm_I),
        .imm_B(imm_B),
        .imm_J(imm_J),
        .jump(jump),
        .branch(branch),
        .branch_taken(branch_taken),
        .jalr_rs1(rs1_data),
        .next_pc(next_pc)
    );


    assign pc_plus_4 = pc + 32'd4;
    assign wb_data = (mem_to_reg == 2'b01) ? mem_read_data :
                     (mem_to_reg == 2'b10) ? pc_plus_4 : alu_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 1'b0;
            fib_result <= 32'd0;
        end else begin
            if (!done) begin
                fib_result <= regfile_inst.registers[10]; 
                if (pc == 32'h0000004C) begin
                    done <= 1'b1;
                end
            end
        end
    end

endmodule
