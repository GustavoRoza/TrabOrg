##Alunos: Gustavo da Fonseca Roza 2211100074 & Henrique Ribeiro Rodrigues 2211100005 

.data
MSG_bemvindo:		        .string "Bem vindo ao BlackJack!\n"
MSG_totalDeCartas: 	        .string "Total de Cartas: "
MSG_pontuacao:		        .string "Pontuacao:\n"
MSG_dealer:		            .string "Dealer: "
MSG_jogador:		        .string "Jogador: "
MSG_desejaJogar:            .string "Deseja jogar? (1 - Sim, 2 - Não): "
MSG_cartas_jogador:         .string "O jogador recebe: "
MSG_dealerMostrarCartas:    .string "O dealer revela: "

# Array para controlar quantas cartas de cada valor foram distribuídas (1-13)
#                             Ás, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K
contador_cartas:      .word    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

cartas_jogador:        .space 40  # Espaço para até 10 cartas
cartas_dealer:         .space 40  # Espaço para até 10 cartas

main:
    # Inicializar pontuações
    li s0, 0       # Pontuação do dealer
    li s1, 0       # Pontuação do jogador
    li s2, 52      # Total de cartas no baralho

    # Exibir mensagem de boas-vindas
    la a0, MSG_bemvindo
    li a7, 4
    ecall   
    

breckjacquiLupi:
    la, a0, MSG_totalDeCartas 
    li a7, a4
    ecall

    mv a0,s2
    li a7,1
    ecall

    #pergunta se deseja jogar
    la a0, MSG_desejaJogar 
    li a7,4
    ecall

    li a7,5
    ecall

    li t0, 1 
    bne a0, t0, finaliza # Se não for 1, finaliza o jogo

    #reinicia o baralho
    li t0, 20
    bge s2,t0, resetaBaralho



finaliza: 
    li a7, 10
    ecall
