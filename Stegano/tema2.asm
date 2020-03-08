%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main

bruteforce_singlebyte_xor:    
    push ebp
    mov ebp, esp
   
    mov ecx, -1
    mov ebx, -1
    mov edx, -1
    
    sub esp, 16 ; allocate space for local variables
    mov dword[ebp - 4], ebx ; lines
    mov dword[ebp - 8], edx ; columns
    mov dword[ebp - 12], ecx ; key
    mov ebx, [img_width]
    imul ebx, -1
    mov dword[ebp - 16], ebx ; beginning of line
    xor ebx, ebx
    
change_number:
    inc dword[ebp - 12] ; key from 0 to 255
    mov dword[ebp - 4], -1 ; lines
    mov dword[ebp - 8], -1 ; columns
    mov ebx, [ebp + 8] ; pointer to the matrix

    ; loop for lines
first_loop:
    inc dword[ebp - 4]
    mov eax, [img_height]
    cmp dword[ebp - 4], eax ; end of lines?
    je change_number
    
    mov dword[ebp - 8], -1 ; restart the columns counter
    
    ; loop for columns
second_loop:     
    inc dword[ebp - 8]
    
    mov edx, dword[ebp - 4]
    imul edx, dword[img_width]
    mov [ebp - 16], edx ; save the beginning of line
    jmp start_comparing
    
vector_iteration:
    xor eax, dword[ebp - 12] ; remake the sign
    add ebx, 4 ; next int
    inc dword[ebp - 8] ; + 1 columns
    mov eax, [img_width]
    cmp dword[ebp - 8], eax
    jge first_loop ; is it the end of column?

start_comparing:

    ; check if the letters are matching
    ; the key word
    ; if not, check next column
    mov eax, [ebx]
    xor eax, dword[ebp - 12]
    cmp eax, 'r'
    jne vector_iteration
    
    xor eax, dword[ebp - 12]
    inc dword[ebp - 8]
    add ebx, 4
    mov eax, [ebx]
    xor eax, dword[ebp - 12]
    cmp eax, 'e'
    jne vector_iteration
   
    xor eax, dword[ebp - 12]
    inc dword[ebp - 8]
    add ebx, 4
    mov eax, [ebx]
    xor eax, dword[ebp - 12]
    cmp eax, 'v'
    jne vector_iteration
    
    inc dword[ebp - 8]
    add ebx, 4
    mov eax, [ebx]
    xor eax, dword[ebp - 12]
    cmp eax, 'i'
    jne vector_iteration
    
    inc dword[ebp - 8]
    add ebx, 4
    mov eax, [ebx]
    xor eax, dword[ebp - 12]
    cmp eax, 'e'
    jne vector_iteration
    
    inc dword[ebp - 8]
    add ebx, 4
    mov eax, [ebx]
    xor eax, dword[ebp - 12]
    cmp eax, 'n'
    jne vector_iteration
    
    inc dword[ebp - 8]
    add ebx, 4
    mov eax, [ebx]
    xor eax, dword[ebp - 12]
    cmp eax, 't'
    jne vector_iteration
    
    ; remake the letter
    xor eax, dword[ebp - 12]
    
    ; beginning of matrix
    mov ebx, [ebp + 8]
    mov ecx, dword[ebp - 16]
    imul ecx, 4 ; the numbers are int
    add ebx, ecx 
    
display:
    ; display until 0
    mov eax, [ebx]
    xor eax, dword[ebp - 12]
    cmp eax, 0
    je ending
    
    cmp dword[ebp + 12], 1
    jne do_not_display ; for ex 2
    PRINT_CHAR eax
    
do_not_display:
    add ebx, 4
    
    jmp display
    
ending:
    cmp dword[ebp + 12], 1
    jne do_not_display2 ; for ex 2
      
    mov eax, [ebp - 12]
    NEWLINE
    PRINT_DEC 4, eax
    
    mov eax, [ebp - 4]
    NEWLINE
    PRINT_DEC 4, eax
    
    ; keep the result in eax
do_not_display2:
    xor eax, eax
    mov ax, [ebp - 12]
    shl eax, 16
    mov ax, [ebp - 4]

    leave
    ret
    
    
predefined_key_encryption:
    push ebp
    mov ebp, esp
    
    mov ecx, [img_width]
    imul ecx, [img_height]
    
    sub esp, 4
    mov [ebp - 4], ecx ; store the size

    mov edx, [ebp + 12] ; matrix
    mov ebx, [ebp + 8] ; line and key
    
    sub esp, 4
    mov [ebp - 8], bx ; store the line
    shr ebx, 16
    sub esp, 4
    mov [ebp - 12], bx ; store the key
    
    xor ecx, ecx
    
    ; decrypt the matrix with the old key
decrypt:
    mov eax, [edx]
    xor eax, [ebp - 12]
    mov [edx],eax
    add edx, 4
    inc ecx
    cmp ecx, dword[ebp - 4]
    jne decrypt
    
    xor ecx, ecx

    mov edx, [ebp + 12] ; matrix
    mov ecx, [ebp - 8] ; the line from ex1
    inc ecx
    imul ecx, [img_width] ; number of chars on a line
    imul ecx, 4 ; size of int
    add edx, ecx ; set the position
    ; positioned where we need to work
    
    ; Modify matrix
    mov dword[edx], "C"
    
    add edx, 4
    mov dword[edx], "'"
    
    add edx, 4
    mov dword[edx], "e"
    
    add edx, 4
    mov dword[edx], "s"
    
    add edx, 4
    mov dword[edx], "t"
    
    add edx, 4
    mov dword[edx], " "
    
    add edx, 4
    mov dword[edx], "u"
    
    add edx, 4
    mov dword[edx], "n"
    
    add edx, 4
    mov dword[edx], " "
                                
    add edx, 4
    mov dword[edx], "p"
    
    add edx, 4
    mov dword[edx], "r"
    
    add edx, 4
    mov dword[edx], "o"
    
    add edx, 4
    mov dword[edx], "v"
    
    add edx, 4
    mov dword[edx], "e"
    
    add edx, 4
    mov dword[edx], "r"
    
    add edx, 4
    mov dword[edx], "b"
    
    add edx, 4
    mov dword[edx], "e"
    
    add edx, 4
    mov dword[edx], " "
    
    add edx, 4
    mov dword[edx], "f"
    
    add edx, 4
    mov dword[edx], "r"
    
    add edx, 4
    mov dword[edx], "a"
    
    add edx, 4
    mov dword[edx], "n"
    
    add edx, 4
    mov dword[edx], "c"
    
    add edx, 4
    mov dword[edx], "a"
    
    add edx, 4
    mov dword[edx], "i"
    
    add edx, 4
    mov dword[edx], "s"
    
    add edx, 4
    mov dword[edx], "."
    
    add edx, 4
    mov dword[edx], 0
    
    ; caluculate the new key
    mov eax, [ebp - 12]
    imul eax, 2
    add eax, 3
    
    xor edx, edx
    cdq
    mov ebx, 5
    idiv ebx
    
    sub eax, 4
    
    mov edx, [ebp + 12] ; matrix
    xor ecx, ecx
       
    ; encrypt the matrix with the new key
encrypt:
    mov ebx, [edx]
    xor ebx, eax
    mov [edx], ebx
    add edx, 4
    inc ecx
    cmp ecx, dword[ebp - 4]
    jne encrypt
    
    ;display matrix
    push dword[img_height]
    push dword[img_width]
    push dword[ebp + 12]
    call print_image
    add esp, 12
                       
    leave
    ret
    
morse_encrypt:
    push ebp
    mov ebp, esp
    
    mov ebx, [ebp + 16] ; index
    
    ; char -> int
    push ebx
    call atoi
    add esp, 4
    
    imul eax, 4

    mov ecx, [ebp + 8] ; matrix
    add ecx, eax ; set the right position
    
    mov edx, [ebp + 12]
    
    ; check every letter and change
    ; the matrix, then go on the next
    ; position in the message and the matrix
morse_code:
    cmp byte[edx], 0
    je string_terminator
    
    cmp byte[edx], 'A'
    jne b_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
   
b_letter:
    cmp byte[edx], 'B'
    jne c_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
c_letter:
    cmp byte[edx], 'C'
    jne d_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
d_letter:
    cmp byte[edx], 'D'
    jne e_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
e_letter:
    cmp byte[edx], 'E'
    jne f_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
f_letter:
    cmp byte[edx], 'F'
    jne g_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
g_letter:
    cmp byte[edx], 'G'
    jne h_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
h_letter:
    cmp byte[edx], 'H'
    jne i_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
i_letter:
    cmp byte[edx], 'I'
    jne j_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
j_letter:
    cmp byte[edx], 'J'
    jne k_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
k_letter:
    cmp byte[edx], 'K'
    jne l_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
l_letter:
    cmp byte[edx], 'L'
    jne m_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
m_letter:
    cmp byte[edx], 'M'
    jne n_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
n_letter:
    cmp byte[edx], 'N'
    jne o_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
o_letter:
    cmp byte[edx], 'O'
    jne p_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
p_letter:
    cmp byte[edx], 'P'
    jne q_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
q_letter:
    cmp byte[edx], 'Q'
    jne r_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
r_letter:
    cmp byte[edx], 'R'
    jne s_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
s_letter:
    cmp byte[edx], 'S'
    jne t_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
t_letter:
    cmp byte[edx], 'T'
    jne u_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
u_letter:
    cmp byte[edx], 'U'
    jne v_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code  
    
v_letter:
    cmp byte[edx], 'V'
    jne w_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
w_letter:
    cmp byte[edx], 'W'
    jne x_letter
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    
x_letter:
    cmp byte[edx], 'X'
    jne y_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code

y_letter:
    cmp byte[edx], 'Y'
    jne z_letter
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
z_letter:
    cmp byte[edx], 'Z'
    jne comma
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
comma:
    cmp byte[edx], ","
    jne one_number 
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
one_number:
    cmp byte[edx], "1"
    jne two_number
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
two_number:
    cmp byte[edx], "2"
    jne three_number
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
three_number:
    cmp byte[edx], "3"
    jne four_number
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
four_number:
    cmp byte[edx], "4"
    jne five_number
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code                     

five_number:
    cmp byte[edx], "5"
    jne six_number
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
six_number:
    cmp byte[edx], "6"
    jne seven_number
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
seven_number:
    cmp byte[edx], "7"
    jne eight_number
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
eight_number:
    cmp byte[edx], "8"
    jne nine_number
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
nine_number:
    cmp byte[edx], "9"
    jne zero_number
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '.'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code
    
zero_number:
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], '-'
    add ecx, 4
    mov dword[ecx], ' '
    inc edx
    add ecx, 4
    jmp morse_code                                                                                                

    ; put the string terminator
string_terminator:
    sub ecx, 4
    mov dword[ecx], 0
    
    ;display matrix
    push dword[img_height]
    push dword[img_width]
    push dword[ebp + 8]
    call print_image
    add esp, 12

    leave
    ret
    
lsb_encode:
    push ebp
    mov ebp, esp
    
    mov ebx, [ebp + 16] ; index
    
    ; char -> int
    push ebx
    call atoi
    add esp, 4
    
    imul eax, 4

    mov esi, [ebp + 8] ; matrix
    sub eax, 4
    add esi, eax ; set the right position
    
    mov edx, [ebp + 12] ; message
    
find_bits:
    ; check for string terminator
    cmp byte[edx], 0
    je string_terminator2
    
    xor ecx, ecx
    
check_bits_of_letter:
    ; check all the 8 bits of a letter
    cmp ecx, 8
    je next_letter
    
    ; checks if the fisrt bit
    ; of the letter is set or not
    mov eax, [edx]
    and eax, 128
    cmp eax, 128
    je set_bit
    
    jmp cleared_bit
    
    ; if it is, set the last bit of
    ; the number in the matrix
set_bit:
    or dword[esi], 1
    jmp continue
    
    ; if it is not, clear the last bit
    ; of the number in the matrix  
cleared_bit:
    and dword[esi], 254
    
    ; next bit of the letter
continue:
    inc ecx
    shl byte[edx], 1
    add esi, 4
    jmp check_bits_of_letter 
    
    ; go the next bit of the letter
next_letter:
    inc edx
    jmp find_bits
    
    ; same thing as above but
    ; for the string terminator
string_terminator2:
    xor ecx, ecx
    
check_bits_of_letter2:
    cmp ecx, 8
    je ending_of_program
    
    and dword[esi], 254
    
    inc ecx
    shl byte[edx], 1
    add esi, 4
    jmp check_bits_of_letter2
    
ending_of_program:
    ;display matrix
    push dword[img_height]
    push dword[img_width]
    push dword[ebp + 8]
    call print_image
    add esp, 12
    
    leave
    ret
    
lsb_decode:
    push ebp
    mov ebp, esp
    
    mov ebx, [ebp + 12] ; index

    ; char -> int
    push ebx
    call atoi
    add esp, 4
    
    ; int = 4 bytes
    imul eax, 4
    
    xor edx, edx
    mov edx, [ebp + 8] ; matrix
    sub eax, 4
    add edx, eax ; set the right position
    
    
search_letter:
    mov eax, 0 ; store the result
    mov ecx, 7 ; make sure to store 8 bits
    
check_end_of_letter:
    ; If we set the 8th bit
    ; go and print the letter
    cmp ecx, -1
    je print_letter
    
    ; if the result is unchanged
    ; this means that the last bit is 1
    ; else, the last bit is 0
    mov ebx, [edx]
    or ebx, 1
    cmp ebx, [edx]
    je one_bit
    
    jmp next_bit
    
one_bit:
    ; mask
    mov ebx, 1
    
    ; if the current bit is the
    ; last one in the letter
    ; do not shift it
    cmp ecx, 0
    je do_not_shift
    
    push ecx
    
    ; shift 1 to the right position and
    ; set the bit
shift_loop:
    shl ebx, 1
    dec ecx
    
    cmp ecx, 0
    jne shift_loop
    
    pop ecx

do_not_shift:
    or eax, ebx
    
    ; next number in the matrix to verify
next_bit:
    add edx, 4
    dec ecx
    jmp check_end_of_letter
    
    ; print he letter
print_letter:    
    cmp eax, 0
    je end_of_program
    
    PRINT_CHAR eax
    
    jmp search_letter
    
          
end_of_program:
    NEWLINE
    leave
    ret
    
blur:
    push ebp
    mov ebp, esp
    
    ; print the data before the
    ; final matrix
    push 0
    push 0
    push dword[img]
    call print_image
    add esp, 12
    
    mov edx, [ebp + 8]
        
    sub esp, 4
    mov dword[ebp - 4], -1 ; lines
    sub esp, 4
    mov dword[ebp - 8], -1 ; columns
    
    ; loop for lines
first_loop2:
    inc dword[ebp - 4]
    mov eax, [img_height]
    cmp dword[ebp - 4], eax ; end of lines?
    jge end_iteration
    
    ; loop for columns
    mov dword[ebp - 8], -1
    
second_loop2:
    inc dword[ebp - 8]
    
    mov eax, [img_width]
    cmp dword[ebp - 8], eax
    jb not_the_last_element ; end of columns?
    
    NEWLINE
    jmp first_loop2
    
not_the_last_element:
    
    ; check for the first line
    cmp dword[ebp - 4], 0
    je skip_operation
    
    ; check for the last line
    mov eax, [img_height]
    dec eax
    cmp dword[ebp - 4], eax
    je skip_operation
    
    ; check for the first column
    cmp dword[ebp - 8], 0
    je skip_operation
    
    ; check for the last column
    mov eax, [img_width]
    dec eax
    cmp dword[ebp - 8], eax
    je skip_operation
    
    ;add curent number
    mov eax, [edx]
    
    ; add the number above him
    mov ecx, [img_width]
    imul ecx, 4
    sub edx, ecx
    add eax, [edx]
    
    ; add the number beneath him
    mov ecx, [img_width]
    imul ecx, 8 ;
    add edx, ecx
    add eax, [edx]
    
    ; add the number from the right
    mov ecx, [img_width]
    imul ecx, 4
    sub edx, ecx
    add edx, 4
    add eax, [edx]
    
    ; add the number from the left
    sub edx, 8
    add eax, [edx]
    add edx, 4
    
    ; division
    push edx
    
    mov ebx, 5
    xor edx, edx
    
    cdq
    idiv ebx
    
    PRINT_DEC 4, eax
    PRINT_CHAR ' '
    
    pop edx
    
    jmp next_element
    
skip_operation:
    ; skip the operations if the line or
    ; column is 0 or size - 1
    PRINT_DEC 4, [edx]
    PRINT_CHAR ' '
    
next_element:
    add edx, 4 ; next element from the matrix
    jmp second_loop2

end_iteration:

    leave
    ret


main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    push 1
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp, 8
    jmp done
solve_task2:
    push 2
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp, 8
    push dword[img]
    push eax
    call predefined_key_encryption
    add esp, 8
    jmp done
solve_task3:
    mov ebx, [ebp + 12]
    push dword[ebx + 16]
    mov ebx, [ebp + 12]
    push dword[ebx + 12]
    push dword[img]
    call morse_encrypt
    add esp, 12
    jmp done
solve_task4:
    mov ebx, [ebp + 12]
    push dword[ebx + 16]
    mov ebx, [ebp + 12]
    push dword[ebx + 12]
    push dword[img]
    call lsb_encode
    add esp, 12
    jmp done
solve_task5:
    mov ebx, [ebp + 12]
    push dword[ebx + 12]
    push dword[img]
    call lsb_decode
    add esp, 8
    jmp done
solve_task6:
    push dword[img]
    call blur
    add esp, 4
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    
