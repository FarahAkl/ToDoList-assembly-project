.MODEL SMALL
.STACK 100H

.DATA
menu DB "To-Do List Program", 10, 13, "1. Add Task", 10, 13, "2. View Tasks", 10, 13, "3. Exit", 10, 13, "$"
prompt DB "Choose an option: $"
add_msg DB "Enter task (max 32 characters): $"
task_list DB 10 DUP(32 DUP(?))  ; 10 groups of 32 uninitialized bytes
task_count DW 0            ; Number of tasks in the list
input_buffer DB 33 DUP(?)  ; Buffer for input (max 32 chars + 1 length byte)
newline DB 10, 13, "$"     ; Newline for formatting
task_full_msg DB "Task list is full!$", "$"
no_tasks_msg DB "No tasks available.$", "$"
error_msg DB "Task length is too long. Please enter a task within 32 characters.$", "$"  ; Error message

.CODE
MAIN PROC
    .STARTUP

MAIN_MENU:
    CALL NEWLINEE
    ; Display menu
    LEA DX, menu
    CALL PRINTSTR

    ; Prompt for choice
    LEA DX, prompt
    CALL PRINTSTR

    ; Get user choice
    MOV AH, 01H                    ; Read single character
    INT 21H
    SUB AL, '0'                    ; Convert ASCII to integer
    CALL NEWLINEE
    ; Handle user choice
    CMP AL, 1                      ; Check option
    JE ADD_TASK
    CMP AL, 2
    JE VIEW_TASKS
    CMP AL, 3
    JMP EXIT_PROGRAM
    JMP MAIN_MENU                  ; Invalid choice, re-display menu

ADD_TASK:
    ; Check if task list is full
    MOV AX, task_count
    CMP AX, 10                     ; Max 10 tasks
    JAE TASK_FULL                  ; If >= 10, jump to TASK_FULL

    ; Prompt for task input
    LEA DX, add_msg
    CALL PRINTSTR

    ; Clear the input buffer
    LEA DI, input_buffer
    MOV BYTE PTR [DI], 32          ; Max length (32 characters)
    MOV BYTE PTR [DI+1], 0         ; Initialize the length to 0

    ; Read task input (using DOS function 0Ah to read a string)
    LEA DX, input_buffer
    MOV AH, 0AH
    INT 21H

    ; Check input length (input_buffer[0] stores the length of input)
    MOV AL, input_buffer[0]
    CMP AL, 0                      ; Ensure at least one character was entered
    JE MAIN_MENU

    ; Copy task to task_list
    MOV AX, task_count             ; Task count index
    MOV BX, 32                     ; Task size (32 bytes)
    MUL BX                         ; Calculate offset: AX = task_count * 32
    LEA SI, input_buffer + 1       ; Start of input (skip length byte)
    LEA DI, task_list              ; Base address of task_list
    ADD DI, AX                     ; Add offset to DI
    MOV CX, 32                     ; Copy 32 bytes (task length)
    REP MOVSB                      ; Copy task to task_list

    ; Increment task count
    INC task_count
    JMP MAIN_MENU                  ; Return to menu

TASK_FULL:
    ; Display "Task list is full" message
    CALL NEWLINEE
    LEA DX, task_full_msg
    CALL PRINTSTR
    JMP MAIN_MENU                  ; Return to menu

VIEW_TASKS:
    ; Check if there are tasks
    MOV AX, task_count
    CMP AX, 0
    JE NO_TASKS

    ; Print all tasks in the list
    XOR BX, BX                     ; Task index = 0 (start from first task)
    MOV CX, task_count             ; Total number of tasks

PRINT_TASKS:
    ; Calculate the offset of the current task
    MOV AX, BX                     ; Task index
    MOV DX, 32                     ; Task size (32 bytes)
    MUL DX                         ; Offset = BX * 32
    LEA DI, task_list              ; Base address of task_list
    ADD DI, AX                     ; Add offset to DI

    ; Display the task
    MOV DX, DI                     ; Point DX to the current task
    CALL PRINTSTR

    CALL NEWLINEE
    ; Move to the next task
    INC BX                         ; Increment task index
    CMP BX, CX                     ; Check if we've printed all tasks
    JL PRINT_TASKS                 ; If BX < CX, repeat
    JMP MAIN_MENU                  ; Return to menu

NO_TASKS:
    ; Display "No tasks available" message
    CALL NEWLINEE
    LEA DX, no_tasks_msg
    CALL PRINTSTR
    JMP MAIN_MENU                  ; Return to menu
    
EXIT_PROGRAM:
    .EXIT
MAIN ENDP
NEWLINEE PROC NEAR
    LEA DX,newline
    MOV AH, 9H
    INT 21H
    RET
NEWLINEE ENDP
PRINTSTR PROC NEAR
    MOV AH, 09H
    INT 21H
    RET
PRINTSTR ENDP
END MAIN