SafeCrackPro
Projeto de uma fechadura digital desenvolvida em SystemVerilog para a placa DE2-115. A senha é formada por quatro dígitos, editados e confirmados individualmente pelos botões.
Implementação dos requisitos
- Edição dos dígitos: digits armazena os quatro números, e current_position_idx indica qual deles está sendo editado.
- Incrementar e decrementar: os botões alteram o dígito selecionado. A contagem é circular: após 9 vem 0, e antes de 0 vem 9.
- Confirmação: o botão de confirmação avança para a próxima posição. Após confirmar o quarto dígito, a FSM compara a sequência com a senha 1234 (PASSWORD = 16'h1234).
- Indicação do resultado: no estado SUCCESS, os nove LEDs verdes acendem por 5 segundos. No estado ERROR, os dezoito LEDs vermelhos acendem por 3 segundos.
- Retorno ao início: ao terminar a contagem, o sistema volta ao estado EDIT, zera os dígitos e seleciona a primeira posição.
- Reset: rstn é ativo em nível baixo e assíncrono; quando acionado, reinicializa o estado, os dígitos, a posição e o temporizador.
Os tempos são calculados a partir de CLK_HZ, cujo valor padrão é 50_000_000 (50 MHz). Os sinais btn são tratados como ativos em nível baixo. Após a inversão, btn[0] confirma, btn[1] incrementa e btn[2] decrementa.
Diagrama de estados
<img width="960" height="257" alt="Captura de tela de 2026-11-18 14-17-50" src="https://github.com/user-attachments/assets/4150e040-89bb-4aa0-a26d-2203629a81a2" />

Diagrama Waveforms:
<img width="1090" height="759" alt="waveform" src="https://github.com/user-attachments/assets/1b1f7f2f-2ee7-499a-9786-813460bf838b" />
[diagramaEstados.pdf](https://github.com/user-attachments/files/35041050/diagramaEstados.pdf)

- Sem debounce ou sincronização dos botões: oscilações mecânicas ou mudanças assíncronas nas entradas podem gerar acionamentos inesperados.
- Botões simultâneos: combinações com mais de um botão pressionado não são tratadas e são ignoradas.
- Sem retorno de posição: depois de confirmar um dígito, não há função para voltar e editá-lo; é necessário reiniciar a entrada.
- Frequência do clock: os tempos de 5 e 3 segundos dependem de CLK_HZ corresponder à frequência real do clock.
