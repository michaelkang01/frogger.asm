#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Michael Kang, 1005981859
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
	#All locations are stored in the top left corner of entity
	displayAddress: .word 0x10008000
	frogLocation: .word 0x10008e38
	car1Location: .word 0x10008a10 #crow1
	car2Location: .word 0x10008a50
	car3Location: .word 0x10008c00 #crow2
	car4Location: .word 0x10008C40
	log1Location: .word 0x10008410 #lrow1
	log2Location: .word 0x10008450
	log3Location: .word 0x10008620 #lrow2
	log4Location: .word 0x10008660
	
.text
	main:
		lw $s0, displayAddress # $s0 stores the base address for display
		lw $s1, frogLocation # $s1 stores the location of the frog
		lw $s2, car1Location # $s2 will be location of car to be accessed
		lw $s3, log1Location # $s3 will be location of log to be accessed
		li $v0, 32
		li $a0, 1000
		syscall
		j main
	
	
	drawBackground:	li $s6, 0x6b9b1e # s5 stores The current color in use, end
			add $s7, $zero, $s0 # s6 stores The current position to draw background
			add $t9, $zero, $ra #stores the none-nested ra so we can go back to main.
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			li $s6, 0x0077be #water
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			li $s6, 0xc2b280 #safe
			jal drawRow
			jal drawRow
			li $s6, 0x696969 #road
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			li $s6, 0x6b9b1e #start
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jr $t9

	drawRow:
		setup:	add $t1, $zero, $zero # Stores incrementing value
			addi $t2, $zero, 64 # Stores end of loop value
			add $t3, $zero, $s6 # Stores our current color in use
			move $t0, $s7 # Moves our display address
		loop:	beq $t1, $t2, exit #Exit on increment reaches end of loop
			sw $t3, 0($t0) 
			add $t0, $t0, 4
			add $t1, $t1, 1
			j loop
		exit:	add $s7, $zero, $t0
			jr $ra
	
	moveCar1:	lw $a0, car1Location
			la $a0, car1Location #get address for firstrowdata
			lw $a1, car1Location
			add $a1, $a1, 4
			sw $a1, 0($a0) #save
			jr $ra
			
	moveCar2:	lw $a0, car2Location
			la $a0, car2Location #get address for firstrowdata
			lw $a1, car2Location
			add $a1, $a1, 4
			sw $a1, 0($a0) #save
			jr $ra
			
	moveCar3:	lw $a0, car3Location
			la $a0, car3Location #get address for firstrowdata
			lw $a1, car3Location
			sub $a1, $a1, 4
			sw $a1, 0($a0) #save
			jr $ra
			
	moveCar4:	lw $a0, car4Location
			la $a0, car4Location #get address for firstrowdata
			lw $a1, car4Location
			sub $a1, $a1, 4
			sw $a1, 0($a0) #save
			jr $ra
			
	moveLog1:	lw $a0, log1Location
			la $a0, log1Location #get address for firstrowdata
			lw $a1, log1Location
			add $a1, $a1, 4
			sw $a1, 0($a0) #save
			jr $ra
			
	moveLog2:	lw $a0, log2Location
			la $a0, log2Location #get address for firstrowdata
			lw $a1, log2Location
			add $a1, $a1, 4
			sw $a1, 0($a0) #save
			jr $ra
			
	moveLog3:	lw $a0, log3Location
			la $a0, log3Location #get address for firstrowdata
			lw $a1, log3Location
			sub $a1, $a1, 4
			sw $a1, 0($a0) #save
			jr $ra
			
	moveLog4:	lw $a0, log4Location
			la $a0, log4Location #get address for firstrowdata
			lw $a1, log4Location
			sub $a1, $a1, 4
			sw $a1, 0($a0) #save
			jr $ra
