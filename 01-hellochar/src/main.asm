; Hello Character program for Linux x86_64
; Demonstrates outputting a single character

global _start                   ; Entry point for the linker

section .text                   ; Code section

_start:
    ; System call: sys_write
    ; rax = 1 (sys_write system call number)
    ; rdi = 1 (file descriptor: stdout)
    ; rsi = address of character to write
    ; rdx = number of bytes to write (1 for single character)
    mov     rax, 1              ; sys_write system call
    mov     rdi, 1              ; stdout file descriptor
    mov     rsi, char_msg       ; address of character to output
    mov     rdx, 1              ; write exactly 1 byte
    syscall                     ; invoke system call

    ; System call: sys_exit
    ; rax = 60 (sys_exit system call number)
    ; rdi = exit status (0 = success)
    mov     rax, 60             ; sys_exit system call
    mov     rdi, 0              ; exit status: 0 (success)
    syscall                     ; invoke system call

section .rodata                 ; Read-only data section
    char_msg:   db 'A'          ; single character 'A'