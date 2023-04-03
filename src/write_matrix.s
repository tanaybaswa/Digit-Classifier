.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 112.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 113.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 114.
# ==============================================================================
write_matrix:

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

    # Open file from s0 = a0.
    mv a1 s0
    li a2 1

    jal fopen

    mv s6 a0
    li t0 -1
    beq s6 t0 open_error

    # malloc space for rows and cols into s4. 
    li a0 8
    jal malloc

    mv s4 a0
    beq s4 zero malloc_error

    # store s2 and s3 into s4 space so we can write it into file s6.
    sw s2 0(s4)
    sw s3 4(s4)

    # write rows and cols into file s3.
    mv a1 s6
    mv a2 s4
    li a3 2
    li a4 4

    jal fwrite

    li t0 2
    mv t1 a0
    bne t1 t0 fwrite_error

    # free s4 because we don't need it anymore.
    mv a0 s4
    jal free

    # the big write
    mul s5 s2 s3
    mv a1 s6
    mv a2 s1
    mv a3 s5
    li a4 4

    jal fwrite

    mv t0 a0
    bne t0 s5 fwrite_error

    # Close the file descriptor s6. Check if equals 0.
    mv a1 s6

    jal fclose

    mv s0 a0
    bne s0 zero fclose_error

    # Finish and go to done.
    j done

open_error:
    li a1 112
    jal exit2

malloc_error:
    li a1 122
    jal exit2

fwrite_error:
    li a1 113
    jal exit2

fclose_error:
    li a1 114
    jal exit2

done:
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
