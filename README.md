# SafeCrackPro

Projeto desenvolvido em SystemVerilog para a placa DE2-115, como uma evolução do SafeCrack FSM apresentado em sala de aula. O sistema permite compor uma senha de quatro dígitos, navegando entre os valores de 0 a 9 por meio dos push buttons e confirmando cada dígito individualmente. Os valores são exibidos nos displays HEX3 a HEX0, enquanto o HEX4 indica a posição atualmente em edição, permitindo ao usuário acompanhar a composição da senha antes de tentar abrir o cofre.

## Principais Bugs e Limitações

**Ausência de filtro de debounce nos botões (KEY[3:1])**: O código detecta a borda de pressionamento por meio de btn_edge = btn_pos & ~btn_prev, mas não implementa um filtro temporal. Na placa física, o repique mecânico (bouncing) pode fazer um único clique ser interpretado como mais de um, alterando o dígito ou avançando a posição indevidamente.

**Senha fixa no código-fonte (1-2-3-4)**: A senha está definida como localparam PASSWORD = 16'h1234. Portanto, não pode ser modificada pelo usuário durante a execução.

**Tentativas ilimitadas**: O sistema não contabiliza erros consecutivos nem aplica bloqueio. Depois dos três segundos de sinalização vermelha, uma nova tentativa pode ser realizada normalmente.

**Entradas inativas durante a sinalização**: Enquanto a FSM está nos estados SUCCESS ou ERROR, os botões de edição e confirmação não são processados. Durante esse período, somente o reset (KEY[0]) pode interromper o funcionamento.

**Sem retorno para dígitos já confirmados**: Depois de confirmar uma posição, o usuário avança para a próxima e não consegue voltar para editar o dígito anterior. Para reiniciar a entrada, é necessário utilizar o reset ou aguardar o fim da sinalização.

**Pressionamento simultâneo de botões**: A FSM reconhece apenas os padrões individuais de confirmação, incremento ou decremento. Se dois ou mais botões forem pressionados ao mesmo tempo, a combinação não corresponde a nenhum desses padrões e é ignorada.

## Descrição como os requisitos foram implementados

**Visão geral**: O módulo safecrackpro_fsm implementa uma máquina de estados finitos com três estados: EDIT, SUCCESS e ERROR. A FSM recebe o clock, o reset e os três botões de controle. Como saídas, fornece os quatro dígitos informados, a posição atualmente selecionada e os sinais de controle dos LEDs vermelhos e verdes. A senha correta é 1234 e os tempos de sinalização são de cinco segundos para acerto e três segundos para erro.

**Os quatro dígitos e os displays**: Os quatro dígitos são armazenados no sinal digits, com quatro bits para cada posição. O registrador current_position_idx indica qual dígito está sendo editado, utilizando os índices de 0 a 3. No top-level, os valores são enviados aos displays de sete segmentos, enquanto a posição selecionada pode ser apresentada no HEX4 como um número de 1 a 4. Apenas o dígito selecionado é alterado durante a edição.

**Estado inicial e reset (KEY[0])**: O reset é assíncrono e ativo em nível baixo (rstn). Quando acionado, a FSM retorna ao estado EDIT, zera os quatro dígitos, seleciona a primeira posição, zera o temporizador e apaga os LEDs. O reset pode ser acionado durante a edição ou enquanto os LEDs de resultado estão acesos.

**Um clique, uma ação**: Os botões físicos são ativos em nível baixo. Por isso, o sinal btn é invertido em btn_pos, fazendo com que nível alto represente um botão pressionado. O sinal btn_prev armazena o valor anterior, e btn_edge identifica a transição de solto para pressionado. Assim, manter um botão pressionado não gera novas ações continuamente. O mapeamento utilizado é: KEY[1] confirma, KEY[2] incrementa e KEY[3] decrementa.

**Mudando o valor do dígito**: No estado EDIT, KEY[2] incrementa o dígito selecionado. Quando o valor chega a 9, o próximo incremento retorna para 0. KEY[3] decrementa o valor e, quando o dígito está em 0, retorna para 9. Esse comportamento circular (wrap-around) mantém os valores entre 0 e 9.

**Confirmando e avançando**: Ao pressionar KEY[1], se a posição atual não for a última, current_position_idx é incrementado e a edição passa para o próximo dígito. Na quarta posição, a FSM compara os quatro dígitos com a senha PASSWORD. Essa verificação é realizada diretamente no estado EDIT, no momento da confirmação do último dígito.

**Verificando a senha e sinalizando o resultado**: Se a sequência informada corresponder a 1234, a FSM passa para SUCCESS e acende os nove LEDs verdes. Caso contrário, passa para ERROR e acende os dezoito LEDs vermelhos. O temporizador conta ciclos do clock até atingir o tempo configurado. Com CLK_HZ = 50_000_000, são utilizados 250.000.000 ciclos para os cinco segundos de sucesso e 150.000.000 ciclos para os três segundos de erro.

**Retorno ao início**: Ao terminar a contagem em SUCCESS ou ERROR, a FSM retorna para EDIT, zera o temporizador e os quatro dígitos e seleciona novamente a primeira posição, permitindo uma nova tentativa.

## Diagrama de estados

<img width="960" height="257" alt="Captura de tela de 2026-11-18 14-17-50" src="https://github.com/user-attachments/assets/46bc6eb6-ed67-458e-91af-c8587022db72" />


## Diagrama Waveform:

<img width="1090" height="759" alt="waveform" src="https://github.com/user-attachments/assets/54c86abb-ff8e-4e46-bbc5-dd010c466378" />
