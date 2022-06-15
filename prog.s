# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by Ching Wan Hern (z5083848), June 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state

## Provides:
	.globl	main
#	.globl	decideCell
#	.globl	neighbours
#	.globl	copyBackAndShow


########################################################################
## Global data
	.data
msg1:	.asciiz "# Iterations: "
msg2:	.asciiz "=== After iteration "
msg3:	.asciiz " ===\n"
eol:	.asciiz "\n"

# .TEXT <main>
	.text
main:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7
# Uses:		$a0, $v0, $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $t0, $t1, $t2
# Clobbers:	...

# Locals:	...

# Structure:
#	main
#	-> [prologue]
#	-> ...
#	-> [epilogue]

# Code:

	# set up stack frame
	sw	$fp, -4($sp)			# push $fp onto stack
	la	$fp, -4($sp)			# set up $fp
	sw	$ra, -4($fp)			# save return address
	sw	$s0, -8($fp)			# save $s0 to use as int maxiters
	sw	$s1, -12($fp)			# save $s1 to use as int n
	sw	$s2, -16($fp)			# save $s2 to use as int i
	sw	$s3, -20($fp)			# save $s3 to use as int j
	sw	$s4, -24($fp)			# save $s4 to use as int nn
	sw	$s5, -28($fp)			# save $s5 to use as pointer to board
	sw	$s6, -32($fp)			# save $s6 to use as pointer to newBoard
	sw	$s7, -36($fp)			# save $s7 to use as int N
	addi	$sp, $sp, -40		# reset $sp to last pushed item

	# printf("Iterations: ")
	la	$a0, msg1
	li	$v0, 4
	syscall

	# scanf("%d", $v0)
	li		$v0, 5
	syscall

	# Initialise variables
	move   $s0, $v0			 	# maxiters = $v0
	li     $s1, 1     		 	# n = 1
	li     $s2, 0     		 	# i = 0
	li     $s3, 0     			# j = 0
	la     $s5, board			# s5 = pointer to board
	la     $s6, newBoard		# s6 = pointer to newBoard
	lw     $s7, N			 	# N = N


loopn:
	li     $s2, 0     		 	# i = 0
	j      loopi             	# jump to loopi

continuen:
	# printf ("=== After iteration ")
	la	$a0, msg2
	li	$v0, 4
	syscall
	# printf ("%d", n)
	move	$a0, $s1
	li		$v0, 1
	syscall
	# printf (" ===\n")
	la	$a0, msg3
	li	$v0, 4
	syscall

	# Calling copyBackAndShow()
	jal	   copyBackAndShow		# copyBackAndShow()

	# Increment n
	addi   $s1, $s1, 1       	# n++
	ble	   $s1, $s0, loopn   	# if (n <= maxiters) loopn
	
	# Finish iterations
	j main__post

loopi:
	li     $s3, 0     		 	# j = 0
	j      loopj            	# jump and link to loopj

continuei:
	# Increment i
	addi   $s2, $s2, 1      	# i++
	blt	   $s2, $s7, loopi  	# if (i < N) loopi
	j	   continuen

loopj:
	# Calling neighbours()
	move   $a0, $s2
	move   $a1, $s3
	jal    neighbours
	move   $s4, $v0			 	# nn = neighbours (i, j)

	# Calling decideCell()
	# Address of board[i][j] = $t1 + sizeof(data) * (N * i + j)
	mul    $t0, $s7, $s2	 	# t0 = N * i
	add	   $t0, $t0, $s3	 	# t0 = N * i + j
	add    $t0, $t0, $s5	 	# t0 = $t1 + 1(N * i + j)
	lb     $t2, 0($t0)		 	# t2 = value in board[i][j]

	move   $a0, $t2
	move   $a1, $s4
	jal    decideCell

	# Address of newBoard[i][j] = $t1 + sizeof(data) * (N * i + j)
	mul    $t0, $s7, $s2	 	# t0 = N * i
	add	   $t0, $t0, $s3	 	# t0 = N * i + j
	add    $t0, $t0, $s6	 	# t0 = $t1 + 1(N * i + j)
	sb     $v0, 0($t0)		 	# newboard[i][j] = decideCell (board[i][j], nn)

	# Increment j
	addi   $s3, $s3, 1       	# j++
	blt	   $s3, $s7, loopj   	# if (j < N) loopj
	j 	   continuei


main__post:
	# tear down stack frame
	lw	$s7, -36($fp)			# Restore $s7 value
	lw	$s6, -32($fp)			# Restore $s6 value
	lw	$s5, -28($fp)			# Restore $s5 value
	lw	$s4, -24($fp)			# Restore $s4 value
	lw	$s3, -20($fp)			# Restore $s3 value
	lw	$s2, -16($fp)			# Restore $s2 value
	lw	$s1, -12($fp)			# Restore $s1 value
	lw	$s0, -8($fp)			# Restore $s0 value
	lw	$ra, -4($fp)			# Restore $ra for return
	la	$sp, 4($fp)				# Restore $sp (remove stack frame)
	lw	$fp, ($fp)				# Restore $fp (remove stack frame)

	# return 0
	li  $v0, 0
	jr	$ra

	# Put your other functions here

# decideCell ####################################################
### decideCell() function
	.text
	.globl	decideCell
decideCell:
	# Required code:
	#	char ret;
	#	if (old == 1) {
	#		if (nn < 2)
	#			ret = 0;
	#		else if (nn == 2 || nn == 3)
	#			ret = 1;
	#		else
	#			ret = 0;
	#	} else if (nn == 3) {
	#		ret = 1;
	#	} else {
	#		ret = 0;
	#	}
	#	return ret;

	# Set up stack frame
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)				# to hold int old
    sw   $s1, 8($sp)				# to hold int nn

	# Initialise variables
	move $s0, $a0					# old = old
	move $s1, $a1					# nn = nn

	# Algorithm starts
	beq  $s0, 1, dec_old			# if (old == 1) dec_old
	beq  $s1, 3, dec_ret1			# if (nn == 3) dec_ret1
	j    dec_ret0					# else dec_ret0

dec_old:
	beq  $s1, 2, dec_ret1			# if (nn == 2) dec_ret1
	beq  $s1, 3, dec_ret1			# if (nn == 3) dec_ret1
	j dec_ret0						# else dec_ret0

dec_ret0:
	li   $v0, '0'					# ret = 0
	j dec_exit

dec_ret1:
	li   $v0, '1'					# ret = 1

	# Clean up stack frame
dec_exit:
	lw   $ra, 0($sp)        		# Read registers from stack
	lw   $s0, 4($sp)
	lw   $s1, 8($sp)
	addi $sp, $sp, 12       		# Bring back stack pointer
	jr $ra							# Return




# neighbours ####################################################
### neighbours() function
	.text
	.globl	neighbours
neighbours:
	# Required code:
	# 	int nn = 0;
	#	for (int x = -1; x <= 1; x++) {
	#		for (int y = -1; y <= 1; y++) {
	#			if (i + x < 0 || i + x > N - 1) continue;
	#			if (j + y < 0 || j + y > N - 1) continue;
	#			if (x == 0 && y == 0) continue;
	#			if (board[i + x][j + y] == 1) nn++;
	#		}
	#	}
	#	return nn;

	# Set up stack frame
    addi $sp, $sp, -32
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)				# to hold int nn
    sw   $s1, 8($sp)				# to hold int i
    sw   $s2, 12($sp)				# to hold int j
    sw   $s3, 16($sp)				# to hold int x
    sw   $s4, 20($sp)				# to hold int y
    sw   $s5, 24($sp)				# to hold pointer to board
	sw   $s6, 28($sp)				# to hold int N

	# Initialise variables
	li	 $s0, 0						# nn = 0
	move $s1, $a0					# i = i
	move $s2, $a1					# j = j
	li   $s3, -1					# x = -1
	li   $s4, -1					# y = -1
	la   $s5, board					# s5 = pointer to board
	lw   $s6, N						# N = N

	# Algorithm starts
nei_loopx:
	li   $s4, -1					# y = -1
	jal  nei_loopy					# jump and link to loopy

	# Increment x
	addi $s3, $s3, 1				# x++
	ble  $s3, 1, nei_loopx			# if (x <= 1) loopx

	# Finish looping
	move $v0, $s0
	j nei_exit

nei_loopy:
	add  $t0, $s1, $s3				# t0 = i + x
	blt  $t0, $0, nei_continuey		# if (i + x < 0) continue

	addi $t1, $s6, -1				# t1 = N - 1
	bgt  $t0, $t1, nei_continuey	# if (i + x > N - 1) continue

	add  $t0, $s2, $s4				# t0 = j + y
	blt  $t0, $0, nei_continuey		# if (j + y < 0) continue

	bgt  $t0, $t1, nei_continuey	# if (j + y > N - 1) continue

	beqz $s3, nei_condition			# if (x == 0) go to nei_condition
									# to check if (y == 0)

nei_continue:
	add $t1, $s1, $s3				# t1 = i + x
	add $t2, $s2, $s4				# t2 = j + y

	# Address of board[i + x][j + y] = $s5 + sizeof(data) * (N(i + x) + (j + y))
	mul    $t0, $s6, $t1	 		# t0 = N(i + x)
	add	   $t0, $t0, $t2	 		# t0 = N(i + x)+(j + y)
	add    $t0, $t0, $s5			# t0 = $s5 + N(i + x)+(j + y)
	lb     $t3, 0($t0)		 		# t3 = value in board[i + x][j + y]

	beq	   $t3, 0, nei_continuey    # if (board[i + x][j + y] == 0) continue
	addi   $s0, $s0, 1				# nn++

nei_continuey:
	# Increment y
	addi $s4, $s4, 1				# y++
	ble  $s4, 1, nei_loopy			# if (y <= 1) loopy
	jr $ra

nei_condition:
	beqz $s4, nei_continuey			# if (y == 0) continue
	j nei_continue

	# Clean up stack frame
nei_exit:
	lw   $ra, 0($sp)        		# Read registers from stack
	lw   $s0, 4($sp)
	lw   $s1, 8($sp)
	lw   $s2, 12($sp)
	lw   $s3, 16($sp)
	lw   $s4, 20($sp)
	lw   $s5, 24($sp)
	lw   $s6, 28($sp)
	addi $sp, $sp, 32       		# Bring back stack pointer
	jr $ra							# Return




# copyBackAndShow ###############################################
### copyBackAndShow() function
	.text
	.globl	copyBackAndShow
copyBackAndShow:
	# Required code:
	#	for (int i = 0; i < N; i++) {
	#		for (int j = 0; j < N; j++) {
	#			board[i][j] = newboard[i][j];
	#			if (board[i][j] == 0)
	#				putchar ('.');
	#			else
	#				putchar ('#');
	#		}
	#		putchar ('\n');
	#	}

	# Set up stack frame
    addi $sp, $sp, -16
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)				# to hold int i
    sw   $s1, 8($sp)				# to hold int j
	sw   $s2, 12($sp)				# to hold int N

	# Initialise variables
	li $s0, 0						# i = 0
	li $s1, 0						# j = 0
	lw $s2, N						# N = N

	# Algorithm starts
cop_loopi:
	li  $s1, 0						# j = 0
	jal cop_loopj

	# Print newline
	la     $a0, eol
	li	   $v0, 4
	syscall

	# Increment i
	addi   $s0, $s0, 1				# i++
	blt    $s0, $s2, cop_loopi  	# if (i < N) cop_loopi

	# Finish looping
	j cop_exit

cop_loopj:
	la     $t1, newBoard
	# Address of newBoard[i][j] = $t1 + sizeof(data) * (N * i + j)
	mul    $t0, $s2, $s0		 	# t0 = N * i
	add	   $t0, $t0, $s1		 	# t0 = N * i + j
	add    $t0, $t0, $t1		 	# t0 = $t1 + 1(N * i + j)
	lb     $t2, 0($t0)			 	# newboard[i][j] = decideCell (board[i][j], nn);

	la     $t1, board
	# Address of board[i][j] = $t1 + sizeof(data) * (N * i + j)
	mul    $t0, $s2, $s0		 # t0 = N * i
	add	   $t0, $t0, $s1		 # t0 = N * i + j
	add    $t0, $t0, $t1		 # t0 = $t1 + 1(N * i + j)

	beq    $t2, '0', cop_dot   	 # if (board[i][j] == 0) cop_dot
	j 	   cop_hash				 # else cop_hash

cop_continuej:
	# Increment j
	addi   $s1, $s1, 1			 # j++
	blt    $s1, $s2, cop_loopj   # if (j < N) cop_loopj
	jr	   $ra

cop_dot:
	li     $t3, 0
	sb     $t3, 0($t0)			 # t2 = value in board[i][j]
	li     $a0, '.'
	li	   $v0, 11
	syscall						 # putchar ('.')
	j      cop_continuej

cop_hash:
	li     $t3, 1
	sb     $t3, 0($t0)			 # t2 = value in board[i][j]
	li     $a0, '#'
	li	   $v0, 11
	syscall						 # putchar ('#')
	j      cop_continuej

	# Clean up stack frame
cop_exit:
	lw   $ra, 0($sp)        	 # Read registers from stack
	lw   $s0, 4($sp)
	lw   $s1, 8($sp)
	lw   $s2, 12($sp)
	addi $sp, $sp, 16       	 # Bring back stack pointer
	jr   $ra					 # Return