.data
argument1: .dword 0b0000000000000000000000000000000000000000001000000000000000000000 #little endian
argument2: .dword 0b0000000000000000000001000000000000000000000000000000000001010000 #little endian
argument3: .dword 0b0000000000000000000000000000000000000000000000000000000001010000 #little endian

str: .string "\nFirst Clear bit of num is "

.text 
data_select:
    jal ra, test_data1
    jal ra, test_data2
    jal ra, test_data3
    j finish

test_data1:
    la, t0, argument1
    j main

test_data2:
    la, t0, argument2
    j main

test_data3:
    la, t0, argument3
main:
    lw, a0, 0(t0)
    lw, a1, 4(t0)
    lw, s0, 0(t0)
    lw, s1, 4(t0)
#### x |= (x >> 1);
    add t1, zero, a0
    add t2, zero, a1
    andi t3, t2, 1 #get 1 bit
    srli t1, t1, 1
    srli t2, t2, 1
    slli t3,t3,31 #move to left
    or t1,t3,t1 
    or a0, a0, t1
    or a1, a1, t2
    
#### x |= (x >> 2);
    add t1, zero, a0
    add t2, zero, a1
    andi t3, t2, 0b11 #get 2 bit
    srli t1, t1, 2
    srli t2, t2, 2
    slli t3,t3,30 #move to left
    or t1,t3,t1 
    or a0, a0, t1
    or a1, a1, t2
    
#### x |= (x >> 4);
    add t1, zero, a0
    add t2, zero, a1
    andi t3, t2, 0b1111 #get 4 bit
    srli t1, t1, 4
    srli t2, t2, 4
    slli t3,t3,28 #move to left
    or t1,t3,t1 
    or a0, a0, t1
    or a1, a1, t2
    
#### x |= (x >> 8);
    add t1, zero, a0
    add t2, zero, a1
    andi t3, t2, 0b11111111 #get 8 bit
    srli t1, t1, 8
    srli t2, t2, 8
    slli t3,t3,24 #move to left
    or t1,t3,t1 
    or a0, a0, t1
    or a1, a1, t2
    
#### x |= (x >> 16);
    add t1, zero, a0
    add t2, zero, a1
    addi t4,zero,16
loop_1:
    andi t3, t2, 1
    slli t3, t3, 31 #move to left
    srli t1, t1, 1
    srli t2, t2, 1
    or t1, t3, t1 
    addi t4, t4, -1
    bne zero, t4, loop_1
    or a0, a0, t1
    or a1, a1, t2
    
#### x |= (x >> 32);
    add t1, zero, a0
    add t2, zero, a1
    addi t4,zero,32
loop_2:
    andi t3, t2, 1
    slli t3, t3, 31 #move to left
    srli t1, t1, 1
    srli t2, t2, 1
    or t1, t3, t1 
    addi t4, t4, -1
    bne zero, t4, loop_2
    or a0, a0, t1
    or a1, a1, t2
    
#### x -= (x >> 1) & 0x5555555555555555
    add t1, zero, a0
    add t2, zero, a1
    andi t3, t2, 1 #get 1 bit
    srli t1, t1, 1
    srli t2, t2, 1
    slli t3, t3, 31 #move to left
    or t1, t3, t1
    lui t3, 0x55555
    addi t3, t3, 0x555
    and t1,t1,t3
    and t2,t2,t3
    
    sub a0, a0, t1
    sub a1, a1, t2
    srli t3, a0, 31
    srli t4, t1, 31
    xor t5, t3, t4
    beq zero, t5, xor_zero
    j xor_one
    xor_zero:
        li t6, 1
        beq t3, t6, borrow
        j end_subtraction
    xor_one:
        li t6, 1
        beq t1, t6, borrow
        j end_subtraction
    j end_subtraction
borrow:
    addi a1, a1, -1  #carry
end_subtraction:
#### x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333);
    add t1, zero, a0
    add t2, zero, a1
    lui t3, 0x33333
    addi t3, t3, 0x333
    and t1,t1,t3
    and t2,t2,t3
    
    andi t3, a1, 0b11 #get 2 bit
    srli a1, a1, 2
    srli a0, a0, 2
    slli t3, t3, 30 #move to left
    or a0, t3, a0
    lui t3, 0x33333
    addi t3, t3, 0x333
    and a0, a0, t3
    and a1, a1, t3
    
    jal add_a0_a1_t1_t2
    
#### x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    add t1, zero, a0
    add t2, zero, a1
    andi t3, t2, 0b1111 #get 4 bit from high 32
    srli t1, t1, 4
    srli t2, t2, 4
    slli t3, t3, 28 #move to left
    or t1, t3, t1

    jal add_a0_a1_t1_t2
    
    lui t3, 0x0f0f0
    li t6,0b111100001111
    add t3, t3, t6
    and a0, a0, t3
    and a1, a1, t3
    
#### x += (x >> 8);
    add t1, zero, a0
    add t2, zero, a1
    andi t3, t2, 0b11111111 #get 8 bit
    srli t1, t1, 8
    srli t2, t2, 8
    slli t3,t3,24 #move to left
    or t1,t3,t1 
    jal add_a0_a1_t1_t2
    
#### x += (x >> 16);
    add t1, zero, a0
    add t2, zero, a1
    addi t4,zero,16
loop_3:
    andi t3, t2, 1
    slli t3, t3, 31 #move to left
    srli t1, t1, 1
    srli t2, t2, 1
    or t1, t3, t1 
    addi t4, t4, -1
    bne zero, t4, loop_3
    jal add_a0_a1_t1_t2 

#### x += (x >> 32);
    add t1, zero, a0
    add t2, zero, a1
    addi t4,zero,32
loop_4:
    andi t3, t2, 1
    slli t3, t3, 31 #move to left
    srli t1, t1, 1
    srli t2, t2, 1
    or t1, t3, t1 
    addi t4, t4, -1
    bne zero, t4, loop_4
    jal add_a0_a1_t1_t2 
    
#### (64 - (x & 0x7f));
    andi a0, a0, 0x007f
    li t0,64
    sub a0,t0,a0
    add t0, zero, a0
    addi t1,t1,64
    addi t2,t2,63
find_first_clear: #t0=i,t1=64,t2=63, t3=(63-i) ,t6t5 = k
    beq t0,t1, print
    sub t3, t2, t0
    
    add t5, zero, s0
    add t6, zero, s1
    add t4,zero,t3
    add s3,zero,t3
loop_5:
    andi t3, t6, 1
    slli t3, t3, 31 #move to left
    srli t5, t5, 1
    srli t6, t6, 1
    or t5, t3, t1 
    addi t4, t4, -1
    bne zero, t4, loop_5
    
    and t5,t5,s0
    and t6,t6,s1
    add t4,t5,t6
    beq zero,t4,print #find and break
    addi t0,t0,1
    
    j find_first_clear
     
print:
    la a0, str
    addi a7, zero, 4 
    ecall
    li a7, 1
    mv a0, s3
    ecall
    ret


add_a0_a1_t1_t2:
    srli t5, a0, 31
    srli t6, t1, 31
    xor t4, t5, t6
    add a0, t1, a0
    add a1, t2, a1
    li t3, 1
    beq t3, t4, xor_result_1
    j xor_result_0
xor_result_1: #check if msb = 0
    srli t5 ,a0, 31 #t5 = msb
    beq zero, t5, carry
    j no_carry
xor_result_0:
    li t3, 1
    beq t6, t3, carry
    j no_carry
carry:
    addi a1,a1,1
no_carry:
    ret
finish:
    j finish