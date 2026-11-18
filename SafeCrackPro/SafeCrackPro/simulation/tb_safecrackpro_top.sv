`timescale 1ns/1ps

module tb_safecrackpro_top;

    logic clk;
    logic [3:0] KEY;

    logic [6:0] seg_pos1;
    logic [6:0] seg_pos2;
    logic [6:0] seg_pos3;
    logic [6:0] seg_pos4;
    logic [6:0] seg_cur_pos;

    logic [17:0] led_red;
    logic [8:0] led_green;

    safecrackpro_top dut (
        .clk(clk),
        .KEY(KEY),
        .seg_pos1(seg_pos1),
        .seg_pos2(seg_pos2),
        .seg_pos3(seg_pos3),
        .seg_pos4(seg_pos4),
        .seg_cur_pos(seg_cur_pos),
        .led_red(led_red),
        .led_green(led_green)
    );

    // Clock de 50 MHz
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        KEY = 4'b1111;

        // Reset
        KEY[0] = 0;
        #40;
        KEY[0] = 1;
        #40;

        // Incrementa primeiro dígito para 1
        KEY[2] = 0;
        #40;
        KEY[2] = 1;
        #40;

        // Confirma primeiro dígito
        KEY[1] = 0;
        #40;
        KEY[1] = 1;
        #40;

        // Finaliza simulação
        #100;

        $display("Simulacao finalizada.");
        $stop;
    end

endmodule