.model small
.stack 100h

.data
    menu_msg        db 13,10,'=== To-Do List Manager ===',13,10
                    db '1. Add Task',13,10
                    db '2. View Tasks',13,10
                    db '3. Exit',13,10
                    db 'Choose option (1-3): $'
    
    input_msg       db 13,10,'Enter task: $'
    tasks_header    db 13,10,'=== Your Tasks ===',13,10,'$'
    no_tasks_msg    db 13,10,'No tasks available.',13,10,'$'
    task_prefix     db 13,10,'- $'
    max_tasks       equ 10
    max_task_len    equ 50
    
    tasks           db max_tasks * max_task_len dup('$')  ; Array to store tasks
    task_count      db 0                                  ; Counter for number of tasks
    buffer          db max_task_len                       ; Buffer for reading input
                    db ?                                  ; Actual chars read
                    db max_task_len dup('$')             ; Input buffer

.code
main proc
    mov ax, @data
    mov ds, ax
    
menu:
    ; Display menu
    mov ah, 09h
    lea dx, menu_msg
    int 21h
    
    ; Get user choice
    mov ah, 01h
    int 21h
    
    ; Process choice
    cmp al, '1'
    je add_task
    cmp al, '2'
    je view_tasks
    cmp al, '3'
    jne exit_program
    jmp menu

add_task:
    ; Check if max tasks reached
    mov al, task_count
    cmp al, max_tasks
    je menu
    
    ; Display input prompt
    mov ah, 09h
    lea dx, input_msg
    int 21h
    
    ; Read task input
    mov ah, 0Ah
    lea dx, buffer
    int 21h
    
    ; Calculate destination address
    xor ax, ax
    mov al, task_count
    mov bl, max_task_len
    mul bl
    lea si, tasks
    add si, ax
    
    ; Copy input to tasks array
    lea bx, buffer + 2
    mov cl, buffer + 1
    xor ch, ch
copy_loop:
    mov al, [bx]
    mov [si], al
    inc bx
    inc si
    loop copy_loop
    
    ; Increment task count
    inc task_count
    jmp menu

view_tasks:
    ; Display header
    mov ah, 09h
    lea dx, tasks_header
    int 21h
    
    ; Check if there are tasks
    cmp task_count, 0
    je no_tasks
    
    ; Display all tasks
    xor cx, cx
    mov cl, task_count
    lea si, tasks
    
display_loop:
    push cx
    
    ; Display task prefix
    mov ah, 09h
    lea dx, task_prefix
    int 21h
    
    ; Display task
    mov ah, 09h
    mov dx, si
    int 21h
    
    ; Move to next task
    add si, max_task_len
    
    pop cx
    loop display_loop
    jmp menu

no_tasks:
    mov ah, 09h
    lea dx, no_tasks_msg
    int 21h
    jmp menu

exit_program:
    mov ah, 4Ch
    int 21h
main endp
end main