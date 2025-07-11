; Selection Sort program for Linux x86_64
; Demonstrates sorting an array of numbers and visualizing the "bubbling up"
; by printing the array state after each swap.

global _start                    ; Entry point for the linker

section .text                    ; Code section

_start:
    ; Print initial array state message
    mov rsi, initial_msg
    call print_string_null_terminated

    ; Print the initial array content
    mov rsi, array_data          ; Address of the array
    mov rdx, array_size          ; Size of the array
    call print_array_state

    ; Perform selection sort
    call selection_sort

    ; Print final sorted array state message
    mov rsi, sorted_msg
    call print_string_null_terminated

    ; Print the final sorted array content
    mov rsi, array_data
    mov rdx, array_size
    call print_array_state

    ; System call: sys_exit
    ; rax = 60 (sys_exit system call number)
    ; rdi = exit status (0 = success)
    mov rax, 60                  ; sys_exit system call number
    mov rdi, 0                   ; exit status: 0 (success)
    syscall                      ; Invoke system call to exit

; -----------------------------------------------------------------------------
; Function: selection_sort
; Description: Sorts the 'array_data' in ascending order using selection sort.
;              Prints the array state after each swap to visualize "bubbling".
; Registers used: rax, rbx, rcx, rdx, rsi, r8, r9, r10, r11 (caller-saved)
; -----------------------------------------------------------------------------
selection_sort:
    ; Outer loop: iterates from i = 0 to array_size - 2
    ; rcx will serve as the outer loop counter (i)
    mov rcx, 0                  ; rcx = i = 0

outer_loop_selection:
    ; Check if i < array_size - 1
    cmp rcx, array_size
    jge end_selection_sort      ; If i >= array_size - 1, sorting is complete
    dec rcx                     ; Adjust for cmp, as we need to go up to array_size - 2
    inc rcx                     ; Restore rcx to i

    ; Assume the current element is the minimum
    mov r10, rcx                ; r10 = min_idx = i

    ; Inner loop: iterates from j = i + 1 to array_size - 1
    ; r9 will serve as the inner loop counter (j)
    mov r9, rcx                 ; r9 = j = i
    inc r9                      ; r9 = j = i + 1

inner_loop_selection:
    ; Check if j < array_size
    cmp r9, array_size
    jge end_inner_loop_selection ; If j >= array_size, inner loop ends

    ; Compare array[j] with array[min_idx]
    mov rsi, array_data         ; rsi = base address of the array
    mov al, [rsi+r9]            ; al = array[j]
    mov bl, [rsi+r10]           ; bl = array[min_idx]

    cmp al, bl                  ; If array[j] < array[min_idx]
    jge no_new_min              ; If al >= bl, current element is not smaller

    ; Update min_idx if a smaller element is found
    mov r10, r9                 ; r10 = min_idx = j

no_new_min:
    inc r9                      ; Increment inner loop index (j++)
    jmp inner_loop_selection    ; Continue inner loop

end_inner_loop_selection:
    ; Swap array[i] with array[min_idx] if min_idx is not i
    cmp r10, rcx                ; Compare min_idx with i
    je skip_swap                ; If min_idx == i, no swap needed

    ; Perform the swap
    mov rsi, array_data         ; rsi = base address of the array
    mov al, [rsi+rcx]           ; al = array[i]
    mov bl, [rsi+r10]           ; bl = array[min_idx]

    mov [rsi+rcx], bl           ; array[i] = array[min_idx]
    mov [rsi+r10], al           ; array[min_idx] = array[i]

    ; Print array state after swap to visualize bubbling
    ; Push all registers used by selection_sort that need to be preserved
    ; before calling print_array_state, as print_array_state uses many
    ; general purpose registers.
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r9
    push r10
    mov rsi, array_data         ; Pass array address
    mov rdx, array_size         ; Pass array size
    call print_array_state      ; Call the print function
    ; Pop saved registers in reverse order
    pop r10
    pop r9
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

skip_swap:
    inc rcx                     ; Increment outer loop index (i++)
    jmp outer_loop_selection    ; Continue outer loop

end_selection_sort:
    ret                         ; Return from selection_sort

; -----------------------------------------------------------------------------
; Function: print_array_state
; Description: Converts the array of bytes (digits 0-9) to a human-readable
;              string (e.g., "9 1 7 3 ...") and prints it to stdout,
;              followed by a newline.
; Arguments:
;   rsi = address of the array (byte array containing numbers 0-9)
;   rdx = size of the array
; Registers used: rax, rbx, rcx, rdi, rsi, rdx, r8 (caller-saved)
; -----------------------------------------------------------------------------
print_array_state:
    ; Save registers that will be modified by this function
    push rbx                    ; Used for print_buffer_ptr
    push rcx                    ; Used for loop counter
    push rdi                    ; Used for sys_write argument
    push rsi                    ; Original array address
    push rdx                    ; Original array size
    push r8                     ; Temporary for byte value

    mov rbx, print_buffer       ; rbx = pointer to current position in print_buffer
    mov rcx, 0                  ; rcx = loop counter (index into array_data)

print_loop:
    cmp rcx, rdx                ; Compare current index with array size
    jae end_print_loop          ; If index >= size, end loop

    mov r8b, byte [rsi+rcx]     ; r8b = current number from array_data

    ; Convert number (0-9) to its ASCII character representation ('0'-'9')
    add r8b, '0'                ; Add ASCII value of '0' (48) to the digit
    mov byte [rbx], r8b         ; Store ASCII character in print_buffer
    inc rbx                     ; Move print_buffer_ptr forward

    ; Add a space after each number, except the last one
    inc rcx                     ; Increment array index for next iteration
    cmp rcx, rdx                ; Check if this was the last element
    je no_space_after_last      ; If it's the last, skip adding space

    mov byte [rbx], ' '         ; Add a space character
    inc rbx                     ; Move print_buffer_ptr forward

no_space_after_last:
    jmp print_loop              ; Continue to the next element

end_print_loop:
    ; Add a newline character at the end of the printed line
    mov byte [rbx], 10          ; Add newline (ASCII 10)
    inc rbx                     ; Move print_buffer_ptr forward

    ; Call sys_write to print the content of print_buffer
    mov rax, 1                  ; sys_write system call number
    mov rdi, 1                  ; stdout file descriptor
    mov rsi, print_buffer       ; Address of the buffer to write
    sub rbx, print_buffer       ; Calculate the length of the string in the buffer
    mov rdx, rbx                ; rdx = number of bytes to write
    syscall                     ; Invoke system call

    ; Restore saved registers
    pop r8
    pop rdx
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret                         ; Return from print_array_state

; -----------------------------------------------------------------------------
; Function: print_string_null_terminated
; Description: Prints a null-terminated string to stdout.
; Arguments:
;   rsi = address of the null-terminated string
; Registers used: rax, rdi, rsi, rdx (caller-saved)
; -----------------------------------------------------------------------------
print_string_null_terminated:
    ; Save registers that will be modified
    push rbx                    ; Used for string length calculation
    push rsi                    ; Original string address

    mov rbx, rsi                ; rbx = current pointer for length calculation
    xor rax, rax                ; rax = 0 (for null byte comparison)

find_length_loop:
    cmp byte [rbx], al          ; Compare current byte with null (0)
    je found_length             ; If null byte found, length calculation is complete
    inc rbx                     ; Move pointer to the next byte
    jmp find_length_loop        ; Continue searching for null terminator

found_length:
    sub rbx, rsi                ; Calculate length: current pointer - start address
    mov rdx, rbx                ; rdx = length for sys_write

    mov rax, 1                  ; sys_write system call number
    mov rdi, 1                  ; stdout file descriptor
    ; rsi already holds the string address
    syscall                     ; Invoke system call

    ; Restore saved registers
    pop rsi
    pop rbx
    ret                         ; Return from print_string_null_terminated

section .data                    ; Writable data section
    ; The array of 10 single-byte numbers (0-9), initially unsorted
    array_data: db 9, 1, 7, 3, 5, 2, 8, 0, 6, 4
    array_size: equ 10           ; Define the size of the array

    ; Buffer for printing the array state.
    ; Max size: 10 digits + 9 spaces + 1 newline = 20 bytes.
    ; We allocate a bit more for safety.
    print_buffer: resb 25

section .rodata                  ; Read-only data section
    ; Null-terminated messages to be printed
    initial_msg: db "Initial array: ", 10, 0 ; Message with newline and null terminator
    sorted_msg:  db "Sorted array: ", 10, 0  ; Message with newline and null terminator
