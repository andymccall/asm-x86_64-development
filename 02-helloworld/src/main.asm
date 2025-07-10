; Hello World program for Linux x86_64
; Demonstrates outputting a string

global _start                   ; Entry point for the linker

section .text                   ; Code section

_start:
    ; System call: sys_write
    ; rax = 1 (sys_write system call number)
    ; rdi = 1 (file descriptor: stdout)
    ; rsi = address of message to write
    ; rdx = number of bytes to write
    mov     rax, 1              ; sys_write system call
    mov     rdi, 1              ; stdout file descriptor
    mov     rsi, hello_msg      ; address of string to output
    mov     rdx, hello_msg_len  ; number of bytes to write
    syscall                     ; invoke system call

    ; System call: sys_exit
    ; rax = 60 (sys_exit system call number)
    ; rdi = exit status (0 = success)
    mov     rax, 60             ; sys_exit system call
    mov     rdi, 0              ; exit status: 0 (success)
    syscall                     ; invoke system call

section .rodata                 ; Read-only data section
    hello_msg:      db "Hello, World!", 10    ; string with newline (10 = '\n')
    hello_msg_len:  equ $ - hello_msg         ; calculate string length