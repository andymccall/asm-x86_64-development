; Hello Name program for Linux x86_64
; Demonstrates inputting a string and outputting a dynamic string

global _start                     ; Entry point for the linker

section .text                     ; Code section

_start:
    ; --- Prompt for name ---
    ; System call: sys_write (rax = 1)
    ; rdi = 1 (file descriptor: stdout)
    ; rsi = address of prompt message
    ; rdx = number of bytes to write
    mov     rax, 1                ; sys_write system call
    mov     rdi, 1                ; stdout file descriptor
    mov     rsi, prompt_msg       ; address of prompt string
    mov     rdx, prompt_msg_len   ; number of bytes to write
    syscall                       ; invoke system call

    ; --- Read name from user ---
    ; System call: sys_read (rax = 0)
    ; rdi = 0 (file descriptor: stdin)
    ; rsi = address of buffer to store input
    ; rdx = maximum number of bytes to read
    mov     rax, 0                ; sys_read system call
    mov     rdi, 0                ; stdin file descriptor
    mov     rsi, name_buffer      ; address of buffer to store name
    mov     rdx, name_buffer_len  ; max bytes to read (size of buffer)
    syscall                       ; invoke system call
    ; On return, rax holds the actual number of bytes read

    ; Store the actual length of the name read in rbx
    mov     rbx, rax              ; rbx = actual_name_len

    ; Check if anything was read (if rbx is 0, exit)
    cmp     rbx, 0
    je      _exit_program         ; If no bytes read, just exit

    ; --- Process input: Remove trailing newline if present ---
    ; sys_read often includes the newline character (10) if Enter was pressed.
    ; We check the last character read and, if it's a newline, replace it
    ; with a null terminator and decrement the effective length.
    cmp     byte [name_buffer + rbx - 1], 10 ; Check if last char is newline
    jne     .name_processed       ; If not a newline, skip adjustment
    dec     rbx                   ; Decrement length (to exclude newline)
    mov     byte [name_buffer + rbx], 0 ; Null-terminate at the new end
    .name_processed:

    ; --- Construct "Hello, [name]!\n" string in output_buffer ---
    ; rcx will be used as the current offset/length for output_buffer

    ; Copy "Hello, " prefix
    mov     rsi, hello_prefix     ; Source: "Hello, "
    mov     rdi, output_buffer    ; Destination: start of output_buffer
    mov     rcx, 0                ; Initialize output_buffer current length/offset
    mov     rdx, hello_prefix_len ; Number of bytes to copy
    .copy_hello_loop:
        cmp     rdx, 0
        je      .copy_name_to_output
        mov     al, [rsi]         ; Get byte from source
        mov     [rdi], al         ; Put byte into destination
        inc     rsi               ; Move to next source byte
        inc     rdi               ; Move to next destination byte
        inc     rcx               ; Increment output_buffer length
        dec     rdx               ; Decrement bytes to copy
        jmp     .copy_hello_loop

    ; Copy user's name
    .copy_name_to_output:
    mov     rsi, name_buffer      ; Source: user's name
    ; rdi is already at the correct position (after "Hello, ")
    mov     rdx, rbx              ; Number of bytes to copy (actual_name_len)
    .copy_name_loop:
        cmp     rdx, 0
        je      .add_exclamation_newline
        mov     al, [rsi]         ; Get byte from source
        mov     [rdi], al         ; Put byte into destination
        inc     rsi               ; Move to next source byte
        inc     rdi               ; Move to next destination byte
        inc     rcx               ; Increment output_buffer length
        dec     rdx               ; Decrement bytes to copy
        jmp     .copy_name_loop

    ; Add "!\n" suffix
    .add_exclamation_newline:
    mov     byte [rdi], '!'       ; Add '!'
    inc     rdi
    inc     rcx                   ; Increment output_buffer length
    mov     byte [rdi], 10        ; Add newline character (ASCII 10)
    inc     rdi
    inc     rcx                   ; Increment output_buffer length
    ; No null terminator needed for sys_write, as we pass the exact length

    ; --- Print the greeting ---
    ; System call: sys_write (rax = 1)
    ; rdi = 1 (file descriptor: stdout)
    ; rsi = address of the constructed greeting string
    ; rdx = total number of bytes to write (stored in rcx)
    mov     rax, 1                ; sys_write system call
    mov     rdi, 1                ; stdout file descriptor
    mov     rsi, output_buffer    ; address of the greeting string
    mov     rdx, rcx              ; total length of the greeting string
    syscall                       ; invoke system call

    ; --- Exit program ---
    ; System call: sys_exit (rax = 60)
    ; rdi = exit status (0 = success)
    _exit_program:
    mov     rax, 60               ; sys_exit system call
    mov     rdi, 0                ; exit status: 0 (success)
    syscall                       ; invoke system call

section .rodata                   ; Read-only data section
    prompt_msg:       db "Please enter your name: ", 0 ; Null-terminated for convenience, though length is used
    prompt_msg_len:   equ $ - prompt_msg

    hello_prefix:     db "Hello, "
    hello_prefix_len: equ $ - hello_prefix

section .bss                      ; Uninitialized data section
    ; Buffer to store the user's name
    ; Maximum name length + 1 for potential newline + 1 for null terminator
    name_buffer_len   equ 256
    name_buffer:      resb name_buffer_len

    ; Buffer to construct the final output string: "Hello, " + name + "!\n"
    ; hello_prefix_len + name_buffer_len (max name) + 2 (for '!' and '\n')
    output_buffer_len equ hello_prefix_len + name_buffer_len + 2
    output_buffer:    resb output_buffer_len
