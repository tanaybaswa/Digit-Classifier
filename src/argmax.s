.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 120.
# =================================================================
argmax:
    # Prologue
    addi sp sp -24
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)


    mv s0 a0
    mv s1 a1
    lw s2 0(s0)
    li s4 0
    li s3 0
    li t0 1

    bge s1 t0 loop_start
    li a1 120
    jal exit2

loop_start:

    lw t0 0(s0)
    bge s2 t0 loop_continue
    mv s4 s3
    mv s2 t0

loop_continue:

    addi s0 s0 4
    addi s3 s3 1
    bge s3 s1 loop_end
    jal loop_start

loop_end:

    mv a0 s4

    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    addi sp sp 24

    ret
