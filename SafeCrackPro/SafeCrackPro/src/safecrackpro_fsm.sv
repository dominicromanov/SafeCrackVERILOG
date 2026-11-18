
module safecrackpro_fsm #(
    parameter integer CLK_HZ = 50_000_000
)(
    input  logic clk,
    input  logic rstn,
    input  logic [2:0] btn,

    output logic [3:0][3:0] digits,
    output logic [1:0] current_position_idx,

    output logic [17:0] led_red,
    output logic [8:0] led_green
);

    // Estados da maquina
    typedef enum logic [1:0] {
        EDIT,
        SUCCESS,
        ERROR
    } state_t;

    state_t state;

    // Senha correta: 1-2-3-4
    localparam logic [15:0] PASSWORD = 16'h1234;

    // Temporizadores
    localparam logic [31:0] SUCCESS_TIME = CLK_HZ * 5;
    localparam logic [31:0] ERROR_TIME   = CLK_HZ * 3;

    logic [31:0] timer;

    // Deteccao de pressionamento dos botoes
    logic [2:0] btn_pos;
    logic [2:0] btn_prev;
    logic [2:0] btn_edge;

    assign btn_pos  = ~btn;
    assign btn_edge = btn_pos & ~btn_prev;

    // Controle principal
    always_ff @(posedge clk or negedge rstn) begin

        if (!rstn) begin

            state <= EDIT;
            digits <= '0;
            current_position_idx <= 2'd0;
            timer <= 0;
            btn_prev <= 3'b000;

        end else begin

            btn_prev <= btn_pos;

            case (state)

                // EDICAO DOS DIGITOS
                EDIT: begin

                    timer <= 0;

                    case (btn_edge)

                        // KEY[1] - CONFIRMAR
                        3'b001: begin

                            if (current_position_idx == 2'd3) begin

                                if ({digits[0], digits[1],
                                     digits[2], digits[3]} == PASSWORD) begin

                                    state <= SUCCESS;

                                end else begin

                                    state <= ERROR;

                                end

                            end else begin

                                current_position_idx <=
                                    current_position_idx + 1'b1;

                            end

                        end

                        // KEY[2] - INCREMENTAR
                        3'b010: begin

                            if (digits[current_position_idx] == 4'd9)
                                digits[current_position_idx] <= 4'd0;
                            else
                                digits[current_position_idx] <=
                                    digits[current_position_idx] + 1'b1;

                        end

                        // KEY[3] - DECREMENTAR
                        3'b100: begin

                            if (digits[current_position_idx] == 4'd0)
                                digits[current_position_idx] <= 4'd9;
                            else
                                digits[current_position_idx] <=
                                    digits[current_position_idx] - 1'b1;

                        end

                        default: begin
                        end

                    endcase

                end

                // SENHA CORRETA
                SUCCESS: begin

                    if (timer >= SUCCESS_TIME - 1) begin

                        state <= EDIT;
                        digits <= '0;
                        current_position_idx <= 2'd0;
                        timer <= 0;

                    end else begin

                        timer <= timer + 1'b1;

                    end

                end

                // SENHA INCORRETA
                ERROR: begin

                    if (timer >= ERROR_TIME - 1) begin

                        state <= EDIT;
                        digits <= '0;
                        current_position_idx <= 2'd0;
                        timer <= 0;

                    end else begin

                        timer <= timer + 1'b1;

                    end

                end

                default: begin

                    state <= EDIT;
                    digits <= '0;
                    current_position_idx <= 2'd0;
                    timer <= 0;

                end

            endcase

        end

    end

    // Controle dos LEDs
    always_comb begin

        led_green = 9'b000000000;
        led_red   = 18'b000000000000000000;

        if (state == SUCCESS)
            led_green = 9'b111111111;

        if (state == ERROR)
            led_red = 18'b111111111111111111;

    end

endmodule
