`timescale 1ns / 1ps


module sim2;
    reg clk;
    reg rst;
    wire [31:0] fib_result;
    wire done;

    cpu_top uut (
        .clk(clk),
        .rst(rst),
        .fib_result(fib_result),
        .done(done)
    );

    initial begin
        clk = 0;
        rst = 1;
        #5 rst = 0;

        wait (done == 1);
        #2;
        $display("SIM2 Fibonacci done, result = %0d", fib_result);
        if (fib_result == 32'd55) begin
            $display("SIM2 PASS: fib(10) = 55");
        end else begin
            $display("SIM2 FAIL: expected 55, got %0d", fib_result);
        end
        $finish;
    end

    always #1 clk = ~clk;
endmodule
