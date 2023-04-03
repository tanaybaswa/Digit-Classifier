.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 123.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 124.
# =======================================================
dot:

    # Prologue
    addi sp sp -32
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)

    mv s0 a0
    mv s1 a1
    mv s2 a2
    mv s3 a3
    mv s4 a4
    li s5 0
    li s6 0
    li t0 1

    blt s2 t0 length_error
    blt s3 t0 stride_error
    blt s4 t0 stride_error
    j loop_start

length_error:
    li a1 123
    jal exit2

stride_error:
    li a1 124
    jal exit2


loop_start:
    lw t2 0(s0)
    lw t3 0(s1)
    mul t2 t3 t2
    add s5 s5 t2

    addi s6 s6 1
    bge s6 s2 loop_end
    li t0 4
    li t1 4
    mul t1 t1 s4
    mul t0 t0 s3
    add s0 s0 t0
    add s1 s1 t1
    j loop_start

loop_end:
    mv a0 s5
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    addi sp sp 32

    ret
