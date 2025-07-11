; Bubble Sort program for Linux x86_64
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

    ; Perform bubble sort
    call bubble_sort

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
; Function: bubble_sort
; Description: Sorts the 'array_data' in ascending order using bubble sort.
;              Prints the array state after each swap to visualize "bubbling".
; Registers used: rax, rbx, rcx, rdx, rsi, r8, r9, r10, r11 (caller-saved)
; -----------------------------------------------------------------------------
bubble_sort:
    ; Outer loop: iterates (n-1) times
    ; rcx will serve as the outer loop counter (i in typical pseudocode)
    ; It goes from (array_size - 1) down to 1.
    mov rcx, array_size         ; rcx = n
    dec rcx                     ; rcx = n-1 (number of passes needed)

outer_loop:
    push rcx                    ; Save outer loop counter (i) on stack
    xor r10, r10                ; r10 = swap_flag = 0 (reset for this pass)

    ; Inner loop: iterates (n-1-i) times
    ; r9 will serve as the inner loop counter (j in typical pseudocode)
    ; It goes from 0 up to (rcx - 1)
    mov r9, 0                   ; r9 = inner loop index (j)

inner_loop:
    ; Compare inner loop index (j) with the current pass limit (rcx)
    cmp r9, rcx                 ; If j >= rcx, end inner loop for this pass
    jge end_inner_loop          ; (rcx effectively holds n-1-i)

    mov rsi, array_data         ; rsi = base address of the array
    mov al, [rsi+r9]            ; al = array[j] (current element)
    mov bl, [rsi+r9+1]          ; bl = array[j+1] (next element)

    cmp al, bl                  ; Compare array[j] with array[j+1]
    jle no_swap                 ; If array[j] <= array[j+1], no swap needed

    ; Swap elements if array[j] > array[j+1]
    mov [rsi+r9], bl            ; array[j] = original array[j+1]
    mov [rsi+r9+1], al          ; array[j+1] = original array[j]
    mov r10, 1                  ; Set swap_flag = 1 (a swap occurred)

    ; Print array state after swap to visualize bubbling
    ; Push all registers used by bubble_sort that need to be preserved
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

no_swap:
    inc r9                      ; Increment inner loop index (j++)
    jmp inner_loop              ; Continue inner loop

end_inner_loop:
    pop rcx                     ; Restore outer loop counter (i)

    ; Check if any swaps occurred in this pass
    cmp r10, 0                  ; If swap_flag is 0, the array is sorted
    je end_bubble_sort          ; Exit if no swaps were made

    loop outer_loop             ; Decrement rcx and jump to outer_loop if rcx != 0

end_bubble_sort:
    ret                         ; Return from bubble_sort

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
