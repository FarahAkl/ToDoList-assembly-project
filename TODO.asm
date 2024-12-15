.MODEL SMALL
.STACK 100H

.DATA
    menu_msg        DB 13,10,'=== To-Do List Manager ===',13,10
                    DB '1. Add Task',13,10
                    DB '2. View Tasks',13,10
                    DB '3. Display Task Count',13,10
                    DB '4. Exit',13,10
                    DB 'Choose option (1-4): $'
    
    input_msg       DB 13,10,'Enter task: $'
    tasks_header    DB 13,10,'=== Your Tasks ===',13,10,'$'
    no_tasks_msg    DB 13,10,'No tasks available.',13,10,'$'
    task_prefix     DB 13,10,'- $'
    task_count_msg  DB 13,10,'Current Number of Tasks: $'
    max_tasks       equ 10
    max_task_len    equ 50
    
    tasks           DB max_tasks * max_task_len dup('$')
    task_count      DB 0
    buffer          DB max_task_len
                    DB ?
                    DB max_task_len dup('$')

.CODE
; Procedure to display the number of tasks
display_task_count PROC NEAR
    ; Display task count message
    MOV AH, 09H
    LEA DX, task_count_msg
    INT 21H

    ; Convert task count to ASCII for display
    MOV AL, task_count
    ADD AL, 30H   ; Convert number to ASCII digit
    MOV DL, AL     ; Move digit to DL for display
    MOV AH, 02H    ; DOS interrupt for character output
    INT 21H

    RET            ; Return to caller
    display_task_count ENDP

main PROC FAR
    .STARTUP
    
menu:
    ; Display menu
    MOV AH, 09H
    LEA DX, menu_msg
    INT 21H
    
    ; Get user choice
    MOV AH, 01H
    INT 21H
    
    ; Process choice
    CMP AL, '1'
    JE add_task
    CMP AL, '2'
    JE view_tasks
    CMP AL, '3'
    JE show_task_count
    CMP AL, '4'
    JMP exit_program
    JMP menu

add_task:
    ; Check if max tasks reached
    MOV AL, task_count
    CMP AL, max_tasks
    JE menu
    
    ; Display input prompt
    MOV AH, 09H
    LEA DX, input_msg
    INT 21H
    
    ; Read task input
    MOV AH, 0AH
    LEA DX, buffer
    INT 21H
    
    ; Calculate destination address
    XOR AX, AX
    MOV AL, task_count
    MOV BL, max_task_len
    MUL BL
    LEA SI, tasks
    ADD SI, AX
    
    ; Copy input to tasks array
    LEA BX, buffer + 2
    MOV CL, buffer + 1
    XOR CH, CH
copy_loop:
    MOV AL, [BX]
    MOV [SI], AL
    INC BX
    INC SI
    LOOP copy_loop
    
    ; Increment task count
    INC task_count
    JMP menu

view_tasks:
    ; Display header
    MOV AH, 09H
    LEA DX, tasks_header
    INT 21H
    
    ; Check if there are tasks
    CMP task_count, 0
    JE no_tasks
    
    ; Display all tasks
    XOR CX, CX
    MOV CL, task_count
    LEA SI, tasks
    
display_loop:
    PUSH CX
    
    ; Display task prefix
    MOV AH, 09H
    LEA DX, task_prefix
    INT 21H
    
    ; Display task
    MOV AH, 09H
    MOV DX, SI
    INT 21H
    
    ; Move to next task
    ADD SI, max_task_len
    
    POP CX
    loop display_loop
    JMP menu

no_tasks:
    MOV AH, 09H
    LEA DX, no_tasks_msg
    INT 21H
    JMP menu

show_task_count:
    CALL display_task_count
    JMP menu

exit_program:
    .EXIT
    main ENDP
END main