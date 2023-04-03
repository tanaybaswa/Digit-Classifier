.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 115.
# ==============================================================================
relu:
    # Prologue
    addi sp sp -20
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)

    mv s0 a0
    mv s1 a1
    li s2 0
    li t0 1
    bge s1 t0 loop_start
    li a1 115
    jal exit2

loop_start:

    lw s3 0(s0)
    bge s3 zero loop_continue
    li s3 0
    sw s3 0(s0)

loop_continue:

    addi s0 s0 4
    addi s2 s2 1
    bge s2 s1 loop_end
    jal loop_start

loop_end:

    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    addi sp sp 20

	ret
