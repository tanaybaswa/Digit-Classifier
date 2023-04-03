.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 116.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 117.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 118.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 119.
# ==============================================================================
read_matrix:
    # Prologue
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)

    mv s0 a0
    mv s1 a1
    mv s2 a2

    # Open file from s0 = a0.
    mv a1 s0
    li a2 0

    jal fopen

    mv s3 a0
    li t0 -1
    beq s3 t0 open_error

    # Malloc space into s4 for rows and cols
    li a0 8
    jal malloc

    mv s4 a0
    beq s4 zero malloc_error

    # Read rows and cols into malloced space s4
    mv a1 s3
    mv a2 s4
    li a3 8

    jal fread

    mv t0 a0
    li t1 8
    bne t0 t1 fread_error

    # Load rows and cols into s1 and s2
    lw t0 0(s4)
    lw t1 4(s4)
    
    sw t0 0(s1)
    sw t1 0(s2)
   
    # Free the space malloced for loading the rows and cols. 
    mv a0 s4
    jal free

    # Now we have s3 pointing to after its first 8 bytes (matrix). We have s1 and s2 storing rows and cols.
    # Time to malloc space for the matrix of size = s1 * s2 * 4 into s4 again. s5 holds number of bytes.
    lw t0 0(s1)
    lw t1 0(s2)
    mul t2 t0 t1
    slli s5 t2 2
    mv a0 s5

    jal malloc

    mv s4 a0
    beq s4 zero malloc_error

    # Call fread with s4 = buffer, s5 = bytes, s3 = file descriptor. 
    mv a1 s3
    mv a2 s4
    mv a3 s5

    jal fread

    mv t0 a0
    bne t0 s5 fread_error

    # Close the file descriptor s3. Check if equals 0.
    mv a1 s3

    jal fclose

    mv t0 a0
    bne t0 zero fclose_error

    # Finish and go to done.
    j done

open_error:
    li a1 117
    jal exit2

malloc_error:
    li a1 116
    jal exit2

fread_error:
    li a1 118
    jal exit2

fclose_error:
    li a1 119
    jal exit2

done:
    mv a0 s4
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    addi sp sp 28

    ret
