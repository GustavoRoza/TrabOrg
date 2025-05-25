# Jogo de Blackjack em Assembly RISC-V
# Desenvolvido para o simulador RARS

.data
MSG_BJ_welcome:             .string "Bem-vindo ao Blackjack!\n"
MSG_BJ_total_cards:         .string "Total de Cartas: "
MSG_BJ_score:               .string "Pontuação:\n"
MSG_BJ_dealer:              .string "	Dealer: "
MSG_BJ_player:              .string "	Jogador: "
MSG_BJ_play:                .string "Deseja jogar? (1 - Sim, 2 - Não): "
MSG_BJ_player_cards:        .string "O jogador recebe: "
MSG_BJ_dealer_show:         .string "O dealer revela: "
MSG_BJ_hidden:              .string " e uma carta oculta\n"
MSG_BJ_hand:                .string "Sua mão: "
MSG_BJ_equals:              .string " = "
MSG_BJ_plus:                .string " + "
MSG_BJ_action:              .string "O que você deseja fazer? (1 - Hit, 2 - Stand): "
MSG_BJ_player_gets:         .string "O jogador recebe: "
MSG_BJ_dealer_hand:         .string "O dealer revela sua mão: "
MSG_BJ_dealer_cont:         .string "O dealer deve continuar pedindo cartas...\n"
MSG_BJ_dealer_gets:         .string "O dealer recebe: "
MSG_BJ_dealer_has:          .string "O dealer tem: "
MSG_BJ_player_bust:         .string "Você estourou! O dealer venceu!\n"
MSG_BJ_dealer_bust:         .string "O dealer estourou! Você venceu!\n"
MSG_BJ_player_win:          .string "Você venceu com uma pontuação maior!\n"
MSG_BJ_dealer_win:          .string "O dealer venceu com uma pontuação maior!\n"
MSG_BJ_tie:                 .string "Empate!\n"
MSG_BJ_newline:             .string "\n"

# Array para controlar quantas cartas de cada valor foram distribuídas (1-13)
#                        Ás, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K
card_count:         .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

# Array para armazenar as cartas do jogador e do dealer
player_cards:       .space 40  # Espaço para até 10 cartas
dealer_cards:       .space 40  # Espaço para até 10 cartas

.text
.globl main

main:
    # Inicializar pontuações
    li s0, 0       # Pontuação do dealer
    li s1, 0       # Pontuação do jogador
    li s2, 52      # Total de cartas no baralho

    # Exibir mensagem de boas-vindas
    la a0, MSG_BJ_welcome
    li a7, 4
    ecall

game_loop:
    # Exibir total de cartas
    la a0, MSG_BJ_total_cards
    li a7, 4
    ecall
    
    mv a0, s2
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecallround_end
    ecall
    
    la a0, MSG_BJ_dealer
    li a7, 4
    ecall
    
    mv a0, s0
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecall
    
    la a0, MSG_BJ_player
    li a7, 4
    ecall
    
    mv a0, s1
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecall
    
    # Perguntar se deseja jogar
    la a0, MSG_BJ_play
    li a7, 4
    ecall
    
    li a7, 5
    ecall
    
    li t0, 1
    bne a0, t0, exit_game
    
    # Reiniciar contagem de cartas se necessário
    li t0, 40
    bge s2, t0, reset_not_needed
    
    # Reiniciar contagem de cartas
    la t0, card_count
    li t1, 0 
    li t2, 13
reset_loop:
    sw zero, 0(t0)
    addi t0, t0, 4
    addi t1, t1, 1
    blt t1, t2, reset_loop
    li s2, 52
    
reset_not_needed:
    # Iniciar nova rodada
    jal new_round
    
    # Verificar se deseja jogar novamente
    j game_loop
exit_game:
    # Encerrar programa
    li a7, 10
    ecall

# Função para iniciar uma nova rodada
new_round:
    # Salvar registradores na pilha
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Inicializar contadores de cartas
    li s3, 0       # Número de cartas do jogador
    li s4, 0       # Número de cartas do dealer
    
    # Distribuir 2 cartas para o jogador
    jal dealerDistribution
    la t0, player_cards
    sb a0, 0(t0)
    addi s3, s3, 1
    addi s2, s2, -1
    
    jal dealerDistribution
    la t0, player_cards 
    sb a0, 1(t0)
    addi s3, s3, 1
    addi s2, s2, -1
    
    # Distribuir 2 cartas para o dealer
    jal dealerDistribution
    la t0, dealer_cards
    sb a0, 0(t0)
    addi s4, s4, 1
    addi s2, s2, -1
    
    jal dealerDistribution
    la t0, dealer_cards
    sb a0, 1(t0)
    addi s4, s4, 1
    addi s2, s2, -1
    
    # Mostrar cartas do jogador
    la a0, MSG_BJ_player_cards
    li a7, 4
    ecall
    
    la t0, player_cards
    lb a0, 0(t0)
    li a7, 1
    ecall
    
    la a0, MSG_BJ_plus
    li a7, 4
    ecall
    
    la t0, player_cards
    lb a0, 1(t0)
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecall
    
    # Mostrar primeira carta do dealer
    la a0, MSG_BJ_dealer_show
    li a7, 4
    ecall
    
    la t0, dealer_cards
    lb a0, 0(t0)
    li a7, 1
    ecall
    
    la a0, MSG_BJ_hidden
    li a7, 4
    ecall
    
    # Turno do jogador
    jal player_turn
    
    # Se o jogador não estourou, é a vez do dealer
    beqz a0, dealer_turn
    
    # Jogador estourou
    la a0, MSG_BJ_player_bust
    li a7, 4
    ecall
    
    # Incrementar pontuação do dealer
    addi s0, s0, 1
    j round_end
    
dealer_turn:
    # Mostrar mão do dealer
    la a0, MSG_BJ_dealer_hand
    li a7, 4
    ecall
    
    la t0, dealer_cards
    lb a0, 0(t0)
    li a7, 1
    ecall
    
    la a0, MSG_BJ_plus
    li a7, 4
    ecall
    
    la t0, dealer_cards
    lb a0, 1(t0)
    li a7, 1
    ecall
    
    # Calcular valor da mão do dealer
    la a0, dealer_cards
    li a1, 2  # Número inicial de cartas
    jal calculate_hand
    mv s5, a0  # Salvar valor da mão do dealer
    
    la a0, MSG_BJ_equals
    li a7, 4
    ecall
    
    mv a0, s5
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecall
    
    # Verificar se o dealer precisa pedir mais cartas
    li t0, 17
    bge s5, t0, compare_hands
    
    la a0, MSG_BJ_dealer_cont
    li a7, 4
    ecall
    
dealer_hit_loop:
    # Verificar se o dealer precisa pedir mais cartas
    li t0, 17
    bge s5, t0, compare_hands
    
    # Dealer pede mais uma carta
    jal dealerDistribution
    la t0, dealer_cards
    add t0, t0, s4
    sb a0, 0(t0)
    addi s4, s4, 1
    addi s2, s2, -1
    
    # Mostrar carta recebida
    la a0, MSG_BJ_dealer_gets
    li a7, 4
    ecall
    
    mv a0, a0
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecall
    
    # Recalcular valor da mão do dealer
    la a0, dealer_cards
    mv a1, s4
    jal calculate_hand
    mv s5, a0
    
    # Mostrar mão atual do dealer
    la a0, MSG_BJ_dealer_has
    li a7, 4
    ecall
    
    # Mostrar todas as cartas do dealer
    la t0, dealer_cards
    li t1, 0
    
dealer_show_cards:
    lb a0, 0(t0)
    li a7, 1
    ecall
    
    addi t1, t1, 1
    beq t1, s4, dealer_show_end
    
    la a0, MSG_BJ_plus
    li a7, 4
    ecall
    
    addi t0, t0, 1
    j dealer_show_cards
    
dealer_show_end:
    la a0, MSG_BJ_equals
    li a7, 4
    ecall
    
    mv a0, s5
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecall
    
    # Verificar se o dealer estourou
    li t0, 21
    ble s5, t0, dealer_hit_loop
    
    # Dealer estourou
    la a0, MSG_BJ_dealer_bust
    li a7, 4
    ecall
    
    # Incrementar pontuação do jogador
    addi s1, s1, 1
    j round_end
    
compare_hands:
    # Calcular valor da mão do jogador
    la a0, player_cards
    mv a1, s3
    jal calculate_hand
    mv s6, a0  # Salvar valor da mão do jogador
    
    # Comparar mãos
    bgt s6, s5, player_wins
    bgt s5, s6, dealer_wins
    
    # Empate
    la a0, MSG_BJ_tie
    li a7, 4
    ecall
    j round_end
    
player_wins:
    la a0, MSG_BJ_player_win
    li a7, 4
    ecall
    addi s1, s1, 1
    j round_end
    
dealer_wins:
    la a0, MSG_BJ_dealer_win
    li a7, 4
    ecall
    addi s0, s0, 1
    j round_end
    
round_end:
    # Restaurar registradores da pilha
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# Função para o turno do jogador
# Retorna 1 se o jogador estourou, 0 caso contrário
player_turn:
    # Salvar registradores na pilha
    addi sp, sp, -4
    sw ra, 0(sp)
    
player_turn_loop:
    # Mostrar mão atual do jogador
    la a0, MSG_BJ_hand
    li a7, 4
    ecall
    
    # Mostrar todas as cartas do jogador
    la t0, player_cards
    li t1, 0
    
player_show_cards:
    lb a0, 0(t0)
    li a7, 1
    ecall
    
    addi t1, t1, 1
    beq t1, s3, player_show_end
    
    la a0, MSG_BJ_plus
    li a7, 4
    ecall
    
    addi t0, t0, 1
    j player_show_cards
    
player_show_end:
    # Calcular valor da mão do jogador
    la a0, player_cards
    mv a1, s3
    jal calculate_hand
    mv s6, a0  # Salvar valor da mão do jogador
    
    la a0, MSG_BJ_equals
    li a7, 4
    ecall
    
    mv a0, s6
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecall
    
    # Verificar se o jogador estourou
    li t0, 21
    bgt s6, t0, player_bust
    
    # Perguntar ação do jogador
    la a0, MSG_BJ_action
    li a7, 4
    ecall
    
    li a7, 5
    ecall
    
    li t0, 1
    bne a0, t0, player_stand
    
    # Jogador pede mais uma carta (Hit)
    jal dealerDistribution
    la t0, player_cards
    add t0, t0, s3
    sb a0, 0(t0)
    addi s3, s3, 1
    addi s2, s2, -1
    
    # Mostrar carta recebida
    la a0, MSG_BJ_player_gets
    li a7, 4
    ecall
    
    mv a0, a0
    li a7, 1
    ecall
    
    la a0, MSG_BJ_newline
    li a7, 4
    ecall
    
    j player_turn_loop
    
player_stand:
    # Jogador para (Stand)
    li a0, 0  # Não estourou
    j player_turn_end
    
player_bust:
    # Jogador estourou
    li a0, 1  # Estourou
    
player_turn_end:
    # Restaurar registradores da pilha
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# Função para calcular o valor da mão
# a0 = endereço do array de cartas
# a1 = número de cartas
# Retorna o valor da mão em a0
calculate_hand:
    li t0, 0       # Contador
    li t1, 0       # Soma
    li t2, 0       # Número de Ases
    
calc_loop:
    beq t0, a1, calc_ases
    
    lb t3, 0(a0)   # Carregar carta
    
    # Verificar valor da carta
    li t4, 1
    beq t3, t4, calc_as
    
    li t4, 11      # Valete
    beq t3, t4, calc_figura
    
    li t4, 12      # Dama
    beq t3, t4, calc_figura
    
    li t4, 13      # Rei
    beq t3, t4, calc_figura
    
    # Carta numerada (2-10)
    add t1, t1, t3
    j calc_next
    
calc_as:
    # Ás (contabilizado depois)
    addi t2, t2, 1
    j calc_next
    
calc_figura:
    # Figura (vale 10)
    addi t1, t1, 10
    
calc_next:
    addi a0, a0, 1
    addi t0, t0, 1
    j calc_loop
    
calc_ases:
    # Processar Ases
    beqz t2, calc_end
    
    # Para cada Ás, decidir se vale 1 ou 11
    li t0, 0
    
calc_ases_loop:
    beq t0, t2, calc_end
    
    # Verificar se adicionar 11 estoura
    addi t3, t1, 11
    li t4, 21
    bgt t3, t4, calc_as_one
    
    # Ás vale 11
    addi t1, t1, 11
    j calc_as_next
    
calc_as_one:
    # Ás vale 1
    addi t1, t1, 1
    
calc_as_next:
    addi t0, t0, 1
    j calc_ases_loop
    
calc_end:
    mv a0, t1
    ret

# Função para distribuir uma carta
# Retorna o valor da carta (1-13) em a0
dealerDistribution:
    # Salvar registradores na pilha
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Gerar número aleatório entre 1 e 13
deal_try:
    li a7, 42      # Syscall para número aleatório
    li a1, 13      # Limite superior (exclusivo)
    ecall
    addi a0, a0, 1 # Ajustar para 1-13
    
    # Verificar se já foram distribuídas 4 cartas desse valor
    la t0, card_count
    addi t0, t0, -4
    slli t1, a0, 2  # Multiplicar por 4 para obter o offset
    add t0, t0, t1
    lw t1, 0(t0)
    
    li t2, 4
    bge t1, t2, deal_try  # Se já distribuiu 4, tenta outro número
    
    # Incrementar contagem dessa carta
    addi t1, t1, 1
    sw t1, 0(t0)
    
    # Restaurar registradores da pilha
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
