; First program for Linux x86_64
; Tests the build environment, the program simply quits

global _start                   ; Entry point for the linker

section .text                   ; Code section

_start:
    ; System call: sys_exit
    ; rax = 60 (sys_exit system call number)
    ; rdi = exit status (0 = success)
    mov     rax, 60             ; sys_exit system call
    mov     rdi, 0              ; exit status: 0 (success)
    syscall                     ; invoke system call