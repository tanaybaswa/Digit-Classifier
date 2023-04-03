.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 121.
    # - If malloc fails, this function terminates the program with exit code 116 (though we will also accept exit code 122).
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

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

    mv s0 a0 # will hold input matrix later on
    mv s1 a1 # s1 is an array of strings, no need of s3 and stuff
    mv s2 a2 # s2 is the print classification
    mv s3 s1 # s3 is s1 lol

    li t0 5
    bne s0 t0 incorrect_number
    j start

incorrect_number:
    li a1 121
    jal exit2

malloc_error:
    li a1 122
    jal exit2

free_error:
    li a1 20
    jal exit2

start:
	# =====================================
    # LOAD MATRICES
    # =====================================

    # load pretrained m0
    # s4 and s5 will be our pointers to ints for reading m0.
    # a0 returned will be allocated to s6, and the matrix space.
    # a1 = s4, a2 = s5, a0 = m0_path = 4(s1)

    lw a0 4(s1)
    addi sp sp -8
    mv a1 sp
    addi a2 sp 4

    jal read_matrix

    mv t0 a0
    mv s6 t0

    lw s4 0(sp)
    lw s5 4(sp)
    addi sp sp 8

    # Load pretrained m1
    # s7 and s8 will be our pointers to ints for reading m1.
    # a0 returned will be allocated to s9, and the matrix space.
    # a1 = s7, a2 = s8, a0 = m1_path = 8(s3)

    lw a0 8(s1)
    addi sp sp -8
    mv a1 sp
    addi a2 sp 4

    jal read_matrix

    mv t0 a0
    mv s9 t0

    lw s7 0(sp)
    lw s8 4(sp)
    addi sp sp 8

    # Load input matrix
    # s10 and s11 will be our pointers to ints for reading input.
    # a0 returned will be allocated to s0, and the matrix space.
    # a1 = s10, a2 = s11, a0 = m1_path = 12(s3)

    lw a0 12(s1)
    addi sp sp -8
    mv a1 sp
    addi a2 sp 4

    jal read_matrix

    mv t0 a0
    mv s0 t0

    lw s10 0(sp)
    lw s11 4(sp)
    addi sp sp 8

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # call malloc for result of 1.
    mv t0 s4
    mv t1 s11
    mul t0 t0 t1
    slli s1 t0 2 # s1 is now rows m0 * cols input * 4
    mv a0 s1

    jal malloc

    mv s1 a0 # s1 holds malloced space
    beq s1 zero malloc_error

    # call matmul
    # after doing 1. we longer need input or m0, just the result. 

    mv a0 s6
    mv a1 s4
    mv a2 s5
    mv a3 s0
    mv a4 s10
    mv a5 s11
    mv a6 s1

    jal matmul # s1 is now the matrix (m0 * input)

    # Free both s6 and s0, because we have used them. The dimensions of
    # the next matrix are still s4 by s11.
    mv a0 s6
    jal free

    mv a0 s0
    jal free

    # Call Relu
    mv s6 s4
    mv s0 s11
    mul s5 s6 s0 # calc number of elems = s5, s6 = rows, s0 = cols

    mv a0 s1
    mv a1 s5

    jal relu
    # s1 is now relu'ed matrix of size s6 * s0.
    # call last matmul m1 * s1 (result matrix). Need malloced space of size 
    # rows m1 * cols s1 = 0(s7)(s4) * s0 = s10. Then we do s10 * 4.

    mv s4 s7
    mul s10 s4 s0
    slli s10 s10 2
    mv a0 s10

    jal malloc

    mv s11 a0
    beq s11 zero malloc_error # got the malloced space now = s11.

    # time to call matmul
    mv a0 s9
    mv a1 s4
    mv a2 s8
    mv a3 s1
    mv a4 s6
    mv a5 s0
    mv a6 s11

    jal matmul

    # so s11 holds our final matrix s4 by s0. I guess we should also free s9 and s1 now.
    mv a0 s9
    jal free

    mv a0 s1
    jal free
    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw s9 16(s3) # s9 now holds the string for output
    mv a0 s9
    mv a1 s11
    mv a2 s4
    mv a3 s0

    jal write_matrix
    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mul s1 s4 s0

    mv a0 s11
    mv a1 s1

    jal argmax

    mv s1 a0

    # Print classification
    bne s2 zero done

    mv a1 s1
    jal print_int

    # Print newline afterwards for clarity
    li a1 '\n'
    jal print_char
done:

    mv a0 s11
    jal free # free s11

    jal num_alloc_blocks
    mv s2 a0
    bne s2 zero free_error # check that we have 0 allocated blocks

    mv a0 s1 # final answer

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
    