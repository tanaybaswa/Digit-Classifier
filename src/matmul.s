.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 125.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 126.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 127.
# =======================================================
matmul:
    # Prologue
    addi sp sp -52
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    sw s7 32(sp)
    sw s8 36(sp)
    sw s9 40(sp)
    sw s10 44(sp)
    sw s11 48(sp)

    mv s0 a0
    mv s1 a1
    mv s2 a2
    mv s3 a3
    mv s4 a4
    mv s5 a5
    mv s6 a6
    li s7 0
    mv s8 s3
    mv s9 s0
    li s10 0
    mv s11 s6

    li t0 1
    blt s1 t0 left
    blt s2 t0 left
    blt s4 t0 right
    blt s5 t0 right
    bne s2 s4 match

    j outer_loop_start

left:
    li a1 125
    jal exit2

right:
    li a1 126
    jal exit2

match:
    li a1 127
    jal exit2

outer_loop_start:
    slli t0 s7 2 # multiply counter by 4, starts at 0
    mul t0 s2 t0 # multiply by number of columns of m0
    add s9 t0 s0 # t0 is the offset from s0, takes to the next row.


inner_loop_start:
    mv a0 s9 # location in m0
    mv a1 s8 # start of m1
    mv a2 s2 # number of columns of m0
    li a3 1 
    mv a4 s5 # number of cols of m1

    jal dot
    
    sw a0 0(s11)
    addi s11 s11 4
    addi s10 s10 1 # add to counter
    addi s8 s8 4
    blt s10 s5 inner_loop_start

inner_loop_end:
    li s10 0
    mv s8 s3
    addi s7 s7 1 # add to counter
    blt s7 s1 outer_loop_start

outer_loop_end:
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    lw s7 32(sp)
    lw s8 36(sp)
    lw s9 40(sp)
    lw s10 44(sp)
    lw s11 48(sp)
    addi sp sp 52

    ret
    

