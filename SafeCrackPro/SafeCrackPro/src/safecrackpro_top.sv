
module safecrackpro_top (
    input  logic        clk,
    input  logic [3:0]  KEY,

    output logic [6:0]  seg_pos1,
    output logic [6:0]  seg_pos2,
    output logic [6:0]  seg_pos3,
    output logic [6:0]  seg_pos4,
    output logic [6:0]  seg_cur_pos,

    output logic [17:0] led_red,
    output logic [8:0]  led_green
);

    logic rstn;
    logic [2:0] btn;
    logic [3:0][3:0] digits;
    logic [1:0] position;

    // Mapeamento dos botoes fisicos
    assign rstn = KEY[0];
    assign btn = {KEY[3], KEY[2], KEY[1]};

    // Maquina de estados
    safecrackpro_fsm fsm_inst (
        .clk                  (clk),
        .rstn                 (rstn),
        .btn                  (btn),
        .digits               (digits),
        .current_position_idx (position),
        .led_red              (led_red),
        .led_green            (led_green)
    );

    // Conversores dos quatro digitos
    bcd_to_7segment_anodo dec_pos1 (
        .bcd (digits[0]),
        .seg (seg_pos1)
    );

    bcd_to_7segment_anodo dec_pos2 (
        .bcd (digits[1]),
        .seg (seg_pos2)
    );

    bcd_to_7segment_anodo dec_pos3 (
        .bcd (digits[2]),
        .seg (seg_pos3)
    );

    bcd_to_7segment_anodo dec_pos4 (
        .bcd (digits[3]),
        .seg (seg_pos4)
    );

    // HEX4 mostra a posicao atual (1 a 4)
    bcd_to_7segment_anodo dec_cur_pos (
        .bcd ({2'b00, position} + 4'd1),
        .seg (seg_cur_pos)
    );

endmodule
