section .data
    board db "123", "456", "789", 0
    msg_prompt db "Enter your move (1-9): ", 0
    msg_invalid db "Invalid move. Try again.", 0xA, 0
    msg_draw db "It's a draw!", 0xA, 0
    msg_player_win db "You win!", 0xA, 0
    msg_computer_win db "Computer wins!", 0xA, 0
    newline db 0xA, 0
    move_input db 0

section .bss
    game_state resb 1

section .text
    global _start

_start:
    call display_board

game_loop:
    ; Get player's move
    call get_player_move
    call display_board
    call check_winner
    cmp rax, 1
    je player_wins

    ; Check for draw
    call check_draw
    cmp rax, 1
    je game_draw

    ; Computer's move
    call get_computer_move
    call display_board
    call check_winner
    cmp rax, 2
    je computer_wins

    ; Check for draw again
    call check_draw
    cmp rax, 1
    je game_draw

    jmp game_loop

player_wins:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_player_win]
    mov rdx, 10
    syscall
    jmp exit_game

computer_wins:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_computer_win]
    mov rdx, 16
    syscall
    jmp exit_game

game_draw:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_draw]
    mov rdx, 12
    syscall
    jmp exit_game

exit_game:
    mov rax, 60
    xor rdi, rdi
    syscall

display_board:
    mov rax, 1
    mov rdi, 1
    lea rsi, [board]
    mov rdx, 12
    syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall
    ret

get_player_move:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_prompt]
    mov rdx, 24
    syscall

    mov rax, 0
    mov rdi, 0
    lea rsi, [move_input]
    mov rdx, 1
    syscall

    movzx rax, byte [move_input]
    sub rax, '1'
    cmp rax, 8
    ja invalid_move
    movzx rbx, byte [board + rax]
    cmp bl, 'X'
    je invalid_move
    cmp bl, 'O'
    je invalid_move
    mov byte [board + rax], 'X'
    ret

invalid_move:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_invalid]
    mov rdx, 25
    syscall
    call get_player_move
    ret

get_computer_move:
    mov rcx, 9
find_move:
    movzx rax, byte [board + rcx - 1]
    cmp al, '1'
    jb skip
    cmp al, '9'
    ja skip
    mov byte [board + rcx - 1], 'O'
    ret
skip:
    loop find_move
    ret

check_winner:
    ; Check rows
    mov rax, 0
    call check_line
    ret

check_draw:
    mov rcx, 9
    mov rax, 1
check_draw_loop:
    movzx rbx, byte [board + rcx - 1]
    cmp bl, '1'
    jb draw_continue
    cmp bl, '9'
    ja draw_continue
    mov rax, 0
    ret
draw_continue:
    loop check_draw_loop
    ret

check_line:
    ; Check all combinations (rows, columns, diagonals)
    ret
