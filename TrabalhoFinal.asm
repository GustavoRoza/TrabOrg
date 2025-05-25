##Alunos: Gustavo da Fonseca Roza 2211100074 & Henrique Ribeiro Rodrigues 2211100005 

.data
MSG_bemvindo:		        .string     "Bem vindo ao BlackJack!\n"
MSG_totalDeCartas: 	        .string     "Total de Cartas: "
MSG_pontuacao:		        .string     "Pontuacao:\n"
MSG_dealer:		            .string     "   Dealer: "
MSG_jogador:		        .string     "   Jogador: "
MSG_desejaJogar:            .string     "Deseja jogar? (1 - Sim, 2 - Não): "
MSG_cartas_jogador:         .string     "O jogador recebe: "
MSG_dealerMostrarCartas:    .string     "O dealer revela: "
MSG_quebraLinha:            .string     "\n"
MSG_cartaOculta:            .string     " e uma carta oculta\n"
MSG_igual:                  .string     " = "   
MSG_mais:                   .string     " + "
MSG_maoDoDealer:            .string     "O dealer revela sua mão: "
MSG_dealerContinua:         .string     "O dealer deve continuar pedindo cartas...\n"
MSG_jogadorEstourou:         .string "Você estourou! O dealer venceu!\n"




# Array para controlar quantas cartas de cada valor foram distribuídas (1-13)
#                             Ás, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K
contador_cartas:      .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

cartas_jogador:        .space 40        # Espaço para até 10 cartas
cartas_dealer:         .space 40        # Espaço para até 10 cartas

.text
.globl main 
main:
    # Inicializar pontuações
    li s0, 0       # Pontuação do dealer
    li s1, 0       # Pontuação do jogador
    li s2, 52      # Total de cartas no baralho

    # Exibir mensagem de boas-vindas
    la a0, MSG_bemvindo
    li a7, 4
    ecall   
    

breckJacquiLoop:
    la a0, MSG_totalDeCartas 
    ecall

    mv a0,s2
    li a7,1
    ecall

    la a0, MSG_quebraLinha
    li a7,4
    ecall

    #pergunta se deseja jogar
    la a0, MSG_desejaJogar 
    ecall

    li a7,5
    ecall

    li t0, 1 
    bne a0, t0, finaliza # Se não for 1, finaliza o jogo

    #reinicia o baralho
    li t0, 12
    bge s2,t0, NaoResetaBaralho 

    # Reseta o baralho
    la t0, contador_cartas
    li t1, 0
    li t2, 13

embaralha:
    sw zero, 0(t0)              # Zera o contador de cartas
    addi t0, t0, 4              # Avança para o próximo contador
    addi t1, t1, 1              # Incrementa o contador de cartas
    blt t1, t2, embaralha 
    li s2, 52

finaliza: 
    li a7, 10
    ecall

NaoResetaBaralho:
    jal novaRodada		    # Iniciar nova rodada
    j breckJacquiLoop		# Verificar se deseja jogar novamente

novaRodada:
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

    # Distribuir 2 cartas para o jogador
    jal dealerDistribution
    la t0, cartas_jogador
    sb a0, 0(t0)
    addi s3, s3, 1
    addi s2, s2, -1

    jal dealerDistribution
    la t0, cartas_jogador 
    sb a0, 1(t0)
    addi s3, s3, 1
    addi s2, s2, -1

    # Distribuir 2 cartas para o dealer
    jal dealerDistribution
    la t0, cartas_dealer
    sb a0, 0(t0)
    addi s4, s4, 1
    addi s2, s2, -1
    
    jal dealerDistribution
    la t0, cartas_dealer
    sb a0, 1(t0)
    addi s4, s4, 1
    addi s2, s2, -1
    
    # Mostrar cartas do jogador
    la a0, MSG_cartas_jogador
    li a7, 4
    ecall
    
    la t0, cartas_jogador
    lb a0, 0(t0)
    li a7, 1
    ecall
    
    la a0, MSG_mais
    li a7, 4
    ecall
    
    la t0, cartas_jogador
    lb a0, 1(t0)
    li a7, 1
    ecall
    
    la a0, MSG_quebraLinha
    li a7, 4
    ecall
    
    # Mostrar primeira carta do dealer
    la a0, MSG_dealerMostrarCartas
    li a7, 4
    ecall
    
    la t0, cartas_dealer
    lb a0, 0(t0)
    li a7, 1
    ecall
    
    la a0, MSG_cartaOculta
    li a7, 4
    ecall

    # Turno do jogador
    jal player_turn
    
    # Se o jogador não estourou, é a vez do dealer
    beqz a0, turnoDoDealer
    
    # Jogador estourou
    la a0, MSG_jogadorEstourou
    li a7, 4
    ecall
    
    # Incrementar pontuação do dealer
    addi s0, s0, 1
    j round_end
    
turnoDoDealer:
    # Mostrar mão do dealer
    la a0, MSG_maoDoDealer
    li a7, 4
    ecall
    
    la t0, cartas_dealer
    lb a0, 0(t0)
    li a7, 1
    ecall
    
    la a0, MSG_mais
    li a7, 4
    ecall
    
    la t0, cartas_dealer
    lb a0, 1(t0)
    li a7, 1
    ecall
    
    # Calcular valor da mão do dealer
    la a0, cartas_dealer
    li a1, 2  # Número inicial de cartas
    jal calculate_hand
    mv s5, a0  # Salvar valor da mão do dealer
    
    la a0, MSG_igual
    li a7, 4
    ecall
    
    mv a0, s5
    li a7, 1
    ecall
    
    la a0, MSG_quebraLinha
    li a7, 4
    ecall
    
    # Verificar se o dealer precisa pedir mais cartas
    li t0, 17
    bge s5, t0, compare_hands
    
    la a0, MSG_dealerContinua
    li a7, 4
    ecall    



