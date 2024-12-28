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
    LEA DX, task_count_msg
    CALL PRINT

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
    LEA DX, menu_msg
    CALL PRINT
    
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
    LEA DX, input_msg
    CALL PRINT
    
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
    LEA DX, tasks_header
    CALL PRINT
    
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
    LEA DX, task_prefix
    CALL PRINT 
    
    ; Display task
    MOV DX, SI
    CALL PRINT
    
    ; Move to next task
    ADD SI, max_task_len
    
    POP CX
    loop display_loop
    JMP menu

no_tasks:

    LEA DX, no_tasks_msg
    CALL PRINT
    JMP menu

show_task_count:
    CALL display_task_count
    JMP menu

exit_program:
    .EXIT
    main ENDP
    PRINT PROC NEAR
        MOV AH, 9H
        INT 21H
        RET
    PRINT ENDP
END main