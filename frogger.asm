#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Michael Kang, ****
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1 (COMPLETE)
# - Milestone 2 (COMPLETE)
# - Milestone 3 (COMPLETE)
# - Milestone 4 (COMPLETE)
# - Milestone 5 (COMPLETE)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# PLANNED FEATURES (6/7 Easy implemented)
# 1. Display Number of Lives (EASY) (COMPLETE)
# 2. Have objects in different rows move at different speeds. (EASY) (COMPLETE)
# 3. Add a third row in each of the water and road sections. (EASY) (COMPLETE)
# 4. Make the frog point in the direction that it's travelling (EASY) (COMPLETE)
# 5. Add a time limit to the game. (EASY) (COMPLETE)
# 6. After final player death, display game over/retry screen. Restart the game if the "retry" option is chosen. (EASY) (COMPLETE)
# 7. Pressing P creates a pause screen, P again will end the pause (EASY) (COMPLETE)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
# - KNOWN BUGS:
#	- All drawn entities (obstacles, frog) flicker constantly. EPILEPSY WARNING.
#		- Background has a slight buffer which reduces the flickering but does not remove it.
#####################################################################
.data
	#All locations are stored in the top left corner of entity
	displayAddress: .word 0x10008000
	frogLocation: .word 0x10009638
	car1Location: .word 0x10008E10 #crow1 - rgiht
	car2Location: .word 0x10008E50
	car3Location: .word 0x10009000 #crow2 -left
	car4Location: .word 0x10009040
	car5Location: .word 0x10009220 #crow3 - right
	car6Location: .word 0x10009260
	log5Location: .word 0x10008818 #lrow3 - left
	log6Location: .word 0x10008858
	log1Location: .word 0x10008620 #lrow2 - right
	log2Location: .word 0x10008660
	log3Location: .word 0x10008410 #lrow1 - left
	log4Location: .word 0x10008450
	carRow1ToMove: .word 20
	carRow2ToMove: .word 24
	carRow3ToMove: .word 16
	logRow1ToMove: .word 12
	logRow2ToMove: .word 16
	logRow3ToMove: .word 28
	carRow1CurM: .word 0
	carRow2CurM: .word 0
	carRow3CurM: .word 0
	logRow1CurM: .word 0
	logRow2CurM: .word 0
	logRow3CurM: .word 0
	frogData: .space 48
	car1Data: .space 128
	car2Data: .space 128
	car3Data: .space 128
	car4Data: .space 128
	car5Data: .space 128
	car6Data: .space 128
	log1Data: .space 128
	log2Data: .space 128
	log3Data: .space 128
	log4Data: .space 128
	log5Data: .space 128
	log6Data: .space 128
	zone1Reached: .word 0
	zone2Reached: .word 0
	zone3Reached: .word 0
	zone4Reached: .word 0
	zone5Reached: .word 0
	zone1Loc: .word 0x10008208
	zone2Loc: .word 0x10008220
	zone3Loc: .word 0x10008238
	zone4Loc: .word 0x10008250
	zone5Loc: .word 0x10008268
	lives: .word 3
	onLog: .word 0 #Counter for if the frog is on the log. Needs all 12 to be considered "on log"
	endOfGameLine: .word 0x10009800
	drawBackgroundBuffer: .word 2
	drawBackgroundCurm: .word 0
	frogFacing: .word 0 #0 is up, 1 is right, 2 is down, 3 is down
	gameTimer: .word 3960 #3960 will be one minute, 7560 two minutes.
	GOTrack: .word 0 #tracks if background has been drawn
	PauseTrack: .word 0
	
.text
	main:
		jal drawBackground
		jal drawCars
		jal drawLogs
		jal drawZones
		jal drawDoneZones
		jal drawFrog
		jal drawLives
		jal drawTimer
		jal checkGameOver
		jal checkCol
		jal checkKey
		jal checkZones
		jal checkTimer
		jal moveEntities
		# testing function only, just to visualize areas better
		#jal testLoc
		li $v0, 32
		li $a0, 16
		syscall
		j main
		
	testLoc:
		li $s5, 0x00ff00
		lw $t0, car1Data
		sw $s5, 0($t0)
		lw $t0, car2Data
		sw $s5, 0($t0)
		li $t0,0x10008E00
		sw $s5, 0($t0)
	
	drawTimer:
		drawTimerSetup:
			move $t9, $ra
			lw $t6, endOfGameLine
			add $t6, $t6, 132
			li $s6, 0x888888
			lw $t1, gameTimer
			li $t0, 360
			div $t1, $t0 #get our timer in terms of 10% bars
			mflo $t1
			add $t2, $zero, $zero
			lw $t5, endOfGameLine #this is where we fill up the bar
			add $t5, $t5, 264
		drawTimerOutline:
			sw $s6, 0($t6)
			sw $s6, 128($t6)
			sw $s6, 256($t6)
			sw $s6, 4($t6)
			sw $s6, 8($t6)
			sw $s6, 12($t6)
			sw $s6, 16($t6)
			sw $s6, 20($t6)
			sw $s6, 24($t6)
			sw $s6, 28($t6)
			sw $s6, 32($t6)
			sw $s6, 36($t6)
			sw $s6, 40($t6)
			sw $s6, 44($t6)
			sw $s6, 172($t6)
			sw $s6, 300($t6)
			sw $s6, 260($t6)
			sw $s6, 264($t6)
			sw $s6, 268($t6)
			sw $s6, 272($t6)
			sw $s6, 276($t6)
			sw $s6, 280($t6)
			sw $s6, 284($t6)
			sw $s6, 288($t6)
			sw $s6, 292($t6)
			sw $s6, 296($t6)
			li $s6, 0xffffff
		drawTimerMain:
			beq $t1, $t2, drawTimerEnd
			mul $t3, $t2, 4
			add $t4, $t3, $t5
			sw $s6, 0($t4)
			add $t2, $t2, 1
			j drawTimerMain
		drawTimerEnd:
			jr $t9
	
	checkTimer:
		lw $t1, gameTimer
		add $t0, $zero, 359
		ble $t1, $t0, gameOver
		la $a0, gameTimer #get address
		sub $t1, $t1, 1 #get and set value - 1
		sw $t1, 0($a0) #save
		jr $ra
		
	
	drawLives:
		drawLivesSetup:
			move $t9, $ra
			lw $s2, lives
			add $t4, $zero, $s2
			add $t5, $zero, $zero
			lw $t6, endOfGameLine
			add $t6, $t6, 112 #we draw the lives right->left.
		drawLivesMain:
			beq $t4, $t5, drawLivesEnd
			move $s1, $t6
			jal drawLivesFrog
			sub $t6, $t6, 20
			add $t5, $t5, 1
			j drawLivesMain
		drawLivesEnd:
			jr $t9
		
	drawDoneZones:
		move $t9, $ra
		lw $s1, zone1Loc
		lw $s2, zone1Reached
		jal drawZoneFrog
		lw $s1, zone2Loc
		lw $s2, zone2Reached
		jal drawZoneFrog
		lw $s1, zone3Loc
		lw $s2, zone3Reached
		jal drawZoneFrog
		lw $s1, zone4Loc
		lw $s2, zone4Reached
		jal drawZoneFrog
		lw $s1, zone5Loc
		lw $s2, zone5Reached
		jal drawZoneFrog
		jr $t9
		
	checkZones:
		move $t9, $ra
		lw $s1, frogLocation
		lw $t0, zone1Loc
		beq $s1, $t0, doneZone1
		lw $t0, zone2Loc
		beq $s1, $t0, doneZone2
		lw $t0, zone3Loc
		beq $s1, $t0, doneZone3
		lw $t0, zone4Loc
		beq $s1, $t0, doneZone4
		lw $t0, zone5Loc
		beq $s1, $t0, doneZone5
		jr $t9
		doneZone1:
			la $a0, zone1Reached
			li $t1, 1
			sw $t1, 0($a0)
			j resetFrog
		doneZone2:
			la $a0, zone2Reached
			li $t1, 1
			sw $t1, 0($a0)
			j resetFrog
		doneZone3:
			la $a0, zone3Reached
			li $t1, 1
			sw $t1, 0($a0)
			j resetFrog
		doneZone4:
			la $a0, zone4Reached
			li $t1, 1
			sw $t1, 0($a0)
			j resetFrog
		doneZone5:
			la $a0, zone5Reached
			li $t1, 1
			sw $t1, 0($a0)
			j resetFrog
		
	drawZones:
		move $t9, $ra
		li $s6, 0x008080
		lw $s2, zone1Loc
		jal drawZone
		lw $s2, zone2Loc
		jal drawZone
		lw $s2, zone3Loc
		jal drawZone
		lw $s2, zone4Loc
		jal drawZone
		lw $s2, zone5Loc
		jal drawZone
		jr $t9
	drawZone:
		drawZoneSetup:
			add $t1, $zero, 4
			add $t2, $zero, $zero
			add $t3, $zero, $s2
		drawZoneMain:
			beq $t1, $t2, drawZoneEnd
			sw $s6, 0($t3)
			sw $s6, 128($t3)
			sw $s6, 256($t3)
			sw $s6, 384($t3)
			add $t3, $t3, 4
			add $t2, $t2, 1
			j drawZoneMain
		drawZoneEnd:
			jr $ra
		
	checkCol:
		move $t9, $ra
		jal checkCarCol
		jal checkLogCol
		jr $t9
		
	checkCarCol:
		checkCarColSetup: 
			move $t8, $ra
			add $t1, $zero, $zero # Stores incrementing value +4 each time
			addi $t2, $zero, 128 # Stores end of loop value = 128, the car data
			la $a0, car1Data
			la $a1, car2Data
			la $a2, car3Data
			la $a3, car4Data
			la $s0, car5Data
			la $s1, car6Data
			la $t5, frogData
		checkCarColMain:
			beq $t1, $t2, checkCarColEnd
			jal checkCarColSub
			add $a0, $a0, 4
			add $a1, $a1, 4
			add $a2, $a2, 4
			add $a3, $a3, 4
			add $t1, $t1, 4
			add $s0, $s0, 4
			add $s1, $s1, 4
			j checkCarColMain
		checkCarColEnd:
			jr $t8
	
	checkCarColSub:
		checkCarColSubSetup:
			add $t3, $zero, $zero
			addi $t4, $zero, 48 # Stores the end of loop value = 44 the frog data
		checkCarColSubMain:
			beq $t3, $t4, checkCarColSubEnd
			lw $t7, 0($t5)
			lw $t6, 0($a0)
			beq $t6, $t7, collisionFound
			lw $t6, 0($a1)
			beq $t6, $t7, collisionFound
			lw $t6, 0($a2)
			beq $t6, $t7, collisionFound
			lw $t6, 0($a3)
			beq $t6, $t7, collisionFound
			lw $t6, 0($s0)
			beq $t6, $t7, collisionFound
			lw $t6, 0($s1)
			beq $t6, $t7, collisionFound
			add $t5, $t5, 4
			add $t3, $t3, 4
			j checkCarColSubMain
		checkCarColSubEnd:
			la $t5, frogData
			jr $ra
	
	checkLogCol:
		checkLogColSetup: 
			move $t8, $ra
			add $t1, $zero, $zero # Stores incrementing value +4 each time
			addi $t2, $zero, 128 # Stores end of loop value = 128, the log data
			la $a0, log1Data
			la $a1, log2Data
			la $a2, log3Data
			la $a3, log4Data
			la $s0, log5Data
			la $s1, log6Data
			la $t5, frogData 
			lw $s7, onLog #stores on the onLog value which we will check if the whole frog is on log
		checkLogColMain:
			beq $t1, $t2, checkLogColEnd
			jal checkLogColSub
			add $a0, $a0, 4
			add $a1, $a1, 4
			add $a2, $a2, 4
			add $a3, $a3, 4
			add $s0, $s0, 4
			add $s1, $s1, 4
			add $t1, $t1, 4
			j checkLogColMain
		checkLogColEnd:
			#we want to check only if the frog is in the water region. 
			#top bound of possible water region
			lw $t5, frogLocation
			li $t0, 0x10008280
			bge $t5, $t0, checkLogColEnd2
			jr $t8
		checkLogColEnd2:
			#lower bound of water region
			lw $t5, frogLocation
			li $t0, 0x100089FC
			ble $t5, $t0, checkLogColEnd3
			jr $t8
		checkLogColEnd3:
			#account for grass
			jal checkLogColGrass
			bne $s7, 12, collisionFound
			jr $t8
	
	checkLogColGrass:
		checkLogColGrassSetup:
			la $t5, frogData
			add $t1, $zero, $zero # Stores incrementing value +4 each time
			addi $t2, $zero, 48 # Stores end of loop value = 128, the log data
		checkLogColGrassMain:
			beq $t1, $t2, checkLogColGrassEnd
			lw $t7, 0($t5)
			li $s3, 0x100089FC
			sgt $t0, $t7, $s3
			add $s7, $s7, $t0
			li $s3, 0x10008400
			slt $t0, $t7, $s3
			add $s7, $s7, $t0
			add $t5, $t5, 4
			add $t1, $t1, 4 # Stores incrementing value +4 each time
			j checkLogColGrassMain
		checkLogColGrassEnd:
			la $t5, frogData
			jr $ra
			
	checkLogColSub:
		checkLogColSubSetup:
			add $t3, $zero, $zero
			addi $t4, $zero, 48 # Stores the end of loop value = 44 the frog data
		checkLogColSubMain:
			beq $t3, $t4, checkLogColSubEnd
			lw $t7, 0($t5)
			lw $t6, 0($a0)
			seq $t0, $t6, $t7
			add $s7, $s7, $t0
			lw $t6, 0($a1)
			seq $t0, $t6, $t7
			add $s7, $s7, $t0
			lw $t6, 0($a2)
			seq $t0, $t6, $t7
			add $s7, $s7, $t0
			lw $t6, 0($a3)
			seq $t0, $t6, $t7
			add $s7, $s7, $t0
			lw $t6, 0($s0)
			seq $t0, $t6, $t7
			add $s7, $s7, $t0
			lw $t6, 0($s1)
			seq $t0, $t6, $t7
			add $s7, $s7, $t0
			add $t5, $t5, 4
			add $t3, $t3, 4
			j checkLogColSubMain
		checkLogColSubEnd:
			la $t5, frogData
			jr $ra
		
	collisionFound:
		la $a0, lives #get address
		lw $a1, lives
		sub $a1, $a1, 1
		sw $a1, 0($a0) #save
		jal resetFrog
		j main
		
	checkGameOver:
		move $t9, $ra
		lw $t0, lives
		li $t1, 0
		beq $t0, $t1, gameOver
		jr $t9
		gameOver:
			jal gameOverScreen
			lw $t7, 0xffff0004
			beq $t7, 0x72, resetGame
			j gameOver
		gameOverScreen:
			setupGO:
				move $t8, $ra
				lw $s0, displayAddress
				li $s6, 0x000000
				add $t1, $zero, $zero # Stores incrementing value
				add $t2, $zero, 1920 # Stores end of loop value
				add $t3, $zero, $s6 # Stores our current color in use
				add $t0, $zero, $s0
				lw $t4, GOTrack
				li $t5, 1
				beq $t4, $t5, exitGO
			loopGO:
				beq $t1, $t2, exitGO #Exit on increment reaches end of loop
				sw $t3, 0($t0) 
				add $t0, $t0, 4
				add $t1, $t1, 1
				j loopGO
			exitGO:
				li $s6, 0xffffff
				add $s1, $s0, 152
				jal drawG
				add $s1, $s1, 20
				jal drawA
				add $s1, $s1, 20
				jal drawM
				add $s1, $s1, 20
				jal drawE
				add $s1, $s1, 580
				jal drawO
				add $s1, $s1, 20
				jal drawV
				add $s1, $s1, 20
				jal drawE
				add $s1, $s1, 20
				jal drawR
				add $s1, $s1, 612
				jal drawLivesFrog
				li $s6, 0x888888
				add $s1, $s1, 588
				jal drawP
				add $s1, $s1, 20
				jal drawR
				add $s1, $s1, 20
				jal drawE
				add $s1, $s1, 20
				jal drawS
				add $s1, $s1, 20
				jal drawS
				add $s1, $s1, 24
				jal drawR
				add $s1, $s1, 576
				jal drawT
				add $s1, $s1, 20
				jal drawO
				add $s1, $s1, 592
				jal drawR
				add $s1, $s1, 20
				jal drawE
				add $s1, $s1, 20
				jal drawT
				add $s1, $s1, 20
				jal drawR
				add $s1, $s1, 20
				jal drawY
				add $s1, $s1, 404
				li $s6, 0xffffff
				sw $s6, 0($s1)
				li $s6, 0x000000
				sw $s6, 0($s1)
				la $a0, GOTrack
				li $a1, 1
				sw $a1, 0($a0)
				jr $t8
			
	resetGame:
		la $a0, lives #get address
		li $a1, 3
		sw $a1, 0($a0) #save
		la $a0, car1Location #get address
		li $a1, 0x10008E10
		sw $a1, 0($a0) #save
		la $a0, car2Location #get address
		li $a1, 0x10008E50
		sw $a1, 0($a0) #save
		la $a0, car3Location #get address
		li $a1, 0x10009000
		sw $a1, 0($a0) #save
		la $a0, car4Location #get address
		li $a1, 0x10009040
		sw $a1, 0($a0) #save
		la $a0, car5Location #get address
		li $a1, 0x10009220
		sw $a1, 0($a0) #save
		la $a0, car6Location #get address
		li $a1, 0x10009260
		sw $a1, 0($a0) #save
		la $a0, log1Location #get address
		li $a1, 0x10008620
		sw $a1, 0($a0) #save
		la $a0, log2Location #get address
		li $a1, 0x10008660
		sw $a1, 0($a0) #save
		la $a0, log3Location 
		li $a1, 0x10008410
		sw $a1, 0($a0) #save
		la $a0, log4Location #get address
		li $a1, 0x10008450
		sw $a1, 0($a0) #save
		la $a0, log5Location 
		li $a1, 0x10008818
		sw $a1, 0($a0) #save
		la $a0, log6Location #get address
		li $a1, 0x10008858
		sw $a1, 0($a0) #save
		la $a0, zone1Reached #get address
		li $a1, 0
		sw $a1, 0($a0) #save
		la $a0, zone2Reached #get address
		li $a1, 0
		sw $a1, 0($a0) #save
		la $a0, zone3Reached #get address
		li $a1, 0
		sw $a1, 0($a0) #save
		la $a0, zone4Reached #get address
		li $a1, 0
		sw $a1, 0($a0) #save
		la $a0, zone5Reached #get address
		li $a1, 0
		sw $a1, 0($a0) #save
		la $a0, gameTimer #get address
		li $a1, 3960
		sw $a1, 0($a0) #save
		la $a0, GOTrack
		li $a1, 0
		sw $a1, 0($a0)
		la $a0, PauseTrack
		li $a1, 0
		sw $a1, 0($a0)
		jal resetFrog
		j main
		
	resetFrog:
		la $a0, frogLocation #get address
		li $a1, 0x10009638 #reset location
		sw $a1, 0($a0) #save
		la $a0, frogFacing #get address
		li $a1, 0 #reset face
		sw $a1, 0($a0) #save
		jr $ra

	checkKey:
		move $t9, $ra
		lw $t7, 0xffff0000
		beq $t7, 1, yesKey
		jr $t9
		yesKey:
			lw $t0, 0xffff0004
			move $t8, $ra
			beq $t0, 0x77, moveUp
			beq $t0, 0x61, moveLeft
			beq $t0, 0x73, moveDown
			beq $t0, 0x64, moveRight
			la $a0, PauseTrack
			li $a1, 0
			sw $a1, 0($a0)
			beq $t0, 0x70, pauseGame
			jr $t8
		moveUp:
			la $a0, frogLocation #get address
			lw $a1, frogLocation
			li $a2, 0x10008000 #comparison value to top of screen
			sub $a2, $a2, 1
			sub $a1, $a1, 128
			sle $t0, $a1, $a2
			beq $t0, $1, stopMove #if it hits out of map, end early
			sw $a1, 0($a0) #save
			la $a0, frogFacing 
			li $t1, 0 # face up
			sw $t1, 0($a0)
			jr $ra
		moveLeft:
			la $a0, frogLocation #get address
			lw $a1, frogLocation
			lw $s0, displayAddress
			sub $a3, $a1, $s0 #a3 will store the current location - the display address, this will be used to check left border
			add $t1, $zero, 128
			div $a3, $t1 #the left border are all multiples of 128
			mfhi $t0 #store the remainder of the division to t0 which we will compare
			sub $a1, $a1, 4
			beq $t0, $0, stopMove
			sw $a1, 0($a0) #save
			la $a0, frogFacing
			li $t1, 3 #face left
			sw $t1, 0($a0)
			jr $ra
		moveDown:
			la $a0, frogLocation #get address
			lw $a1, frogLocation
			li $a2, 0x10009600 #comparison value to bottom of game screen
			add $a2, $a2, 128
			add $a1, $a1, 128
			sle $t0, $a2, $a1
			beq $t0, $1, stopMove #if it hits out of map, end early
			sw $a1, 0($a0) #save
			la $a0, frogFacing
			li $t1, 2 #face down
			sw $t1, 0($a0)
			jr $ra
		moveRight:
			la $a0, frogLocation #get address
			lw $a1, frogLocation
			lw $s0, displayAddress
			sub $a3, $a1, $s0 #a3 will store the current location - the display address, this will be used to check left border
			add $t1, $zero, 112 #used to create the edge we cannot cross
			sub $a3, $a3, $t1
			add $t1, $zero, 128
			div $a3, $t1 #the right border are all multiples of 128-32=96
			mfhi $t0 #store the remainder of the division to t0 which we will compare
			beq $t0, $0, stopMove
			add $a1, $a1, 4
			sw $a1, 0($a0) #save
			la $a0, frogFacing
			li $t1, 1 #face right
			sw $t1, 0($a0)
			jr $ra
		pauseGame:
			jal pauseScreen
			lw $t7, 0xffff0000
			bne $t7, 1, pauseGame
			lw $t7, 0xffff0004
			beq $t7, 0x70, main
			beq $t7, 0x72, resetGame
			j pauseGame
		pauseScreen:
			setupPause:
				move $t8, $ra
				lw $s0, displayAddress
				li $s6, 0x000000
				add $t1, $zero, $zero # Stores incrementing value
				add $t2, $zero, 1536 # Stores end of loop value
				add $t3, $zero, $s6 # Stores our current color in use
				add $t0, $zero, $s0
				lw $t4, PauseTrack
				li $t5, 1
				beq $t4, $t5, exitPause
			loopPause:
				beq $t1, $t2, exitPause #Exit on increment reaches end of loop
				sw $t3, 0($t0) 
				add $t0, $t0, 4
				add $t1, $t1, 1
				j loopPause
			exitPause:
				li $s6, 0xffffff
				add $s1, $s0, 132
				jal drawP
				add $s1, $s1, 20
				jal drawA
				add $s1, $s1, 20
				jal drawU
				add $s1, $s1, 20
				jal drawS
				add $s1, $s1, 20
				jal drawE
				add $s1, $s1, 20
				jal drawD
				li $s6, 0x888888
				add $s1, $s1, 1052
				jal drawP
				add $s1, $s1, 20
				jal drawR
				add $s1, $s1, 20
				jal drawE
				add $s1, $s1, 20
				jal drawS
				add $s1, $s1, 20
				jal drawS
				add $s1, $s1, 24
				jal drawR
				add $s1, $s1, 576
				jal drawT
				add $s1, $s1, 20
				jal drawO
				add $s1, $s1, 592
				jal drawR
				add $s1, $s1, 20
				jal drawE
				add $s1, $s1, 20
				jal drawT
				add $s1, $s1, 20
				jal drawR
				add $s1, $s1, 20
				jal drawY
				add $s1, $s1, 1060
				jal drawP
				add $s1, $s1, 20
				jal drawR
				add $s1, $s1, 20
				jal drawE
				add $s1, $s1, 20
				jal drawS
				add $s1, $s1, 20
				jal drawS
				add $s1, $s1, 24
				jal drawP
				add $s1, $s1, 576
				jal drawT
				add $s1, $s1, 20
				jal drawO
				add $s1, $s1, 576
				jal drawU
				add $s1, $s1, 16
				jal drawN
				add $s1, $s1, 20
				jal drawP
				add $s1, $s1, 20
				jal drawA
				add $s1, $s1, 20
				jal drawU
				add $s1, $s1, 20
				jal drawS
				add $s1, $s1, 16
				jal drawE
				add $s1, $s1, 524
				li $s6, 0xffffff
				sw $s6, 0($s1)
				li $s6, 0x000000
				sw $s6, 0($s1)
				la $a0, PauseTrack
				li $a1, 1
				sw $a1, 0($a0)
				jr $t8
		stopMove:
			jr $ra
	drawFrog:
		setupFrog:
			lw $s1, frogLocation
			add $t1, $zero, $s1
			la $a1, frogData
			lw $s5, frogLocation #s5 stores the current location to store into data
			lw $s2, frogFacing
			li $s6, 0xffc0cb
		mainFrog:
			beq $s2, 0, drawUpFrog
			beq $s2, 1, drawRightFrog
			beq $s2, 2, drawDownFrog
			beq $s2, 3 drawLeftFrog
			jr $ra
		
	drawDownFrog:
		sw $s6, 0($t1)
		sw $s5, 0($a1)
		
		sw $s6, 4($t1)#draw pixel
		add $s5, $t1, 4#get display location of pizel drawn
		
		sw $s5, 4($a1)#store in frogData
		
		sw $s6, 8($t1)
		add $s5, $t1, 8
		
		sw $s5, 8($a1)
		
		sw $s6, 12($t1)
		add $s5, $t1, 12
		
		sw $s5, 12($a1)
		
		sw $s6, 132($t1)
		add $s5, $t1, 132
		
		sw $s5, 16($a1)
		
		sw $s6, 136($t1)
		add $s5, $t1, 136
		
		sw $s5, 20($a1)
		
		sw $s6, 260($t1)
		add $s5, $t1, 260
		
		sw $s5, 24($a1)
		
		sw $s6, 264($t1)
		add $s5, $t1, 264
		
		sw $s5, 28($a1)
		
		sw $s6, 256($t1)
		add $s5, $t1, 256
		
		sw $s5, 32($a1)
		
		sw $s6, 268($t1)
		add $s5, $t1, 268
		
		sw $s5, 36($a1)
		
		sw $s6, 384($t1)
		add $s5, $t1, 384
		
		sw $s5, 40($a1)
		
		sw $s6, 396($t1)
		add $s5, $t1, 396
		
		sw $s5, 44($a1)
		jr $ra	
					
	drawLeftFrog:
		sw $s6, 0($t1)
		sw $s5, 0($a1)
		
		sw $s6, 4($t1)#draw pixel
		add $s5, $t1, 4#get display location of pizel drawn
		
		sw $s5, 4($a1)#store in frogData
		
		sw $s6, 12($t1)
		add $s5, $t1, 12
		
		sw $s5, 8($a1)
		
		sw $s6, 132($t1)
		add $s5, $t1, 132
		
		sw $s5, 12($a1)
		
		sw $s6, 136($t1)
		add $s5, $t1, 136
		
		sw $s5, 16($a1)
		
		sw $s6, 140($t1)
		add $s5, $t1, 140
		
		sw $s5, 20($a1)
		
		sw $s6, 260($t1)
		add $s5, $t1, 260
		
		sw $s5, 24($a1)
		
		sw $s6, 264($t1)
		add $s5, $t1, 264
		
		sw $s5, 28($a1)
		
		sw $s6, 268($t1)
		add $s5, $t1, 268
		
		sw $s5, 32($a1)
		
		sw $s6, 384($t1)
		add $s5, $t1, 384
		
		sw $s5, 36($a1)
		
		sw $s6, 388($t1)
		add $s5, $t1, 388
		
		sw $s5, 40($a1)
		
		sw $s6, 396($t1)
		add $s5, $t1, 396
		
		sw $s5, 44($a1)
		jr $ra		
	
	drawRightFrog:
		sw $s6, 0($t1)
		sw $s5, 0($a1)
		
		sw $s6, 8($t1)#draw pixel
		add $s5, $t1, 8#get display location of pizel drawn
		
		sw $s5, 4($a1)#store in frogData
		
		sw $s6, 12($t1)
		add $s5, $t1, 12
		
		sw $s5, 8($a1)
		
		sw $s6, 128($t1)
		add $s5, $t1, 128
		
		sw $s5, 12($a1)
		
		sw $s6, 132($t1)
		add $s5, $t1, 132
		
		sw $s5, 16($a1)
		
		sw $s6, 136($t1)
		add $s5, $t1, 136
		
		sw $s5, 20($a1)
		
		sw $s6, 256($t1)
		add $s5, $t1, 256
		
		sw $s5, 24($a1)
		
		sw $s6, 260($t1)
		add $s5, $t1, 260
		
		sw $s5, 28($a1)
		
		sw $s6, 264($t1)
		add $s5, $t1, 264
		
		sw $s5, 32($a1)
		
		sw $s6, 384($t1)
		add $s5, $t1, 384
		
		sw $s5, 36($a1)
		
		sw $s6, 392($t1)
		add $s5, $t1, 392
		
		sw $s5, 40($a1)
		
		sw $s6, 396($t1)
		add $s5, $t1, 396
		
		sw $s5, 44($a1)
		jr $ra
	
	drawUpFrog:
		sw $s6, 0($t1)
		sw $s5, 0($a1)
		sw $s6, 12($t1)#draw pixel
		add $s5, $t1, 12#get display location of pizel drawn
		sw $s5, 4($a1)#store in frogData
		sw $s6, 128($t1)
		add $s5, $t1, 128
		sw $s5, 8($a1)
		sw $s6, 132($t1)
		add $s5, $t1, 132
		sw $s5, 12($a1)
		sw $s6, 136($t1)
		add $s5, $t1, 136
		sw $s5, 16($a1)
		sw $s6, 140($t1)
		add $s5, $t1, 140
		sw $s5, 20($a1)
		sw $s6, 260($t1)
		add $s5, $t1, 260
		sw $s5, 24($a1)
		sw $s6, 264($t1)
		add $s5, $t1, 264
		sw $s5, 28($a1)
		sw $s6, 384($t1)
		add $s5, $t1, 384
		sw $s5, 32($a1)
		sw $s6, 388($t1)
		add $s5, $t1, 388
		sw $s5, 36($a1)
		sw $s6, 392($t1)
		add $s5, $t1, 392
		sw $s5, 40($a1)
		sw $s6, 396($t1)
		add $s5, $t1, 396
		sw $s5, 44($a1)
		jr $ra
	
	drawLivesFrog:
		setupLivesFrog:
			add $t1, $zero, $s1
			li $s6, 0xffc0cb
		mainLivesFrog:
			sw $s6, 0($t1)
			sw $s6, 12($t1)#draw pixel
			sw $s6, 128($t1)
			sw $s6, 132($t1)
			sw $s6, 136($t1)
			sw $s6, 140($t1)
			sw $s6, 260($t1)
			sw $s6, 264($t1)
			sw $s6, 384($t1)
			sw $s6, 388($t1)
			sw $s6, 392($t1)
			sw $s6, 396($t1)
			j endLivesFrog
		endLivesFrog:
			jr $ra
	
	drawZoneFrog:
		setupZoneFrog:
			add $t1, $zero, $s1
			beq $s2, 0, endZoneFrog
			li $s6, 0xffc0cb
		mainZoneFrog:
			sw $s6, 0($t1)
			sw $s6, 12($t1)#draw pixel
			sw $s6, 128($t1)
			sw $s6, 132($t1)
			sw $s6, 136($t1)
			sw $s6, 140($t1)
			sw $s6, 260($t1)
			sw $s6, 264($t1)
			sw $s6, 384($t1)
			sw $s6, 388($t1)
			sw $s6, 392($t1)
			sw $s6, 396($t1)
			j endZoneFrog
		endZoneFrog:
			jr $ra
			
	drawBackground:	
		drawBackgroundCheck:
			lw $t0, drawBackgroundBuffer
			lw $t1, drawBackgroundCurm
			move $t9, $ra #stores the none-nested ra so we can go back to main.
			beq $t1, $t0, drawBackgroundMain
			la $a0, drawBackgroundCurm
			add $t1, $t1, 1
			sw $t1, 0($a0)
			jr $t9
		drawBackgroundMain:
			li $s6, 0x6b9b1e # s6 stores The current color in use, end
			lw $s0, displayAddress
			add $s7, $zero, $s0 # s6 stores The current position to draw background
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			li $s6, 0x0077be #water
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			li $s6, 0xc2b280 #safe
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			li $s6, 0x696969 #road
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			li $s6, 0x6b9b1e #start
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			li $s6, 0x000000 #bottom of screen
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			jal drawRow
			la $a0, drawBackgroundCurm
			add $t1, $zero, $zero
			sw $t1, 0($a0)
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
	
	drawCars:
		move $t9, $ra
		lw $s2, car1Location 
		la $s4, car1Data
		jal drawRow1Car
		lw $s2, car2Location 
		la $s4, car2Data
		jal drawRow1Car
		lw $s2, car3Location 
		la $s4, car3Data
		jal drawRow2Car
		lw $s2, car4Location
		la $s4, car4Data
		jal drawRow2Car
		lw $s2, car5Location 
		la $s4, car5Data
		jal drawRow3Car
		lw $s2, car6Location
		la $s4, car6Data
		jal drawRow3Car
		jr $t9
		
	
	drawRow1Car:	#8x4 size
		setupRow1Car:
			li $s6, 0xff0000
			add $t1, $zero, $zero # i in the loop
			add $t2, $zero, 8
			add $t3, $zero, $s2 # incrementing location to draw
			add $t5, $zero, $s2 # stores the location to store into data
			li $t4, 0x10008E00 #setup the part here we have to go shift
			add $t4, $t4, 128
			move $t8, $ra #ra sub for sub function
		mainRow1Car:
			beq $t1, $t2, endRow1Car
			sle $t6, $t4, $t3
			beq $t6, 1, altRow1Car
			beq $t6, 0, regRow1Car
		regRow1Car:
			add $t5, $t3, 0#get display location of pizel drawn
			sw $t5, 0($s4)
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4)
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 384($t3)
			add $s4, $s4, 4
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow1Car
		altRow1Car:
			sub $t5, $t3, 128#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, -128($t3)
			add $t5, $t3, 0#get display location of pizel drawn
			add $s4, $s4, 4#increment to next address
			sw $t5, 0($s4)
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 256($t3)
			add $s4, $s4, 4
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow1Car
		endRow1Car:
			jr $t8
			
	drawRow2Car:	#8x4 size
		setupRow2Car:
			li $s6, 0xff0000
			add $t1, $zero, $zero # i in the loop
			add $t2, $zero, 8
			add $t3, $zero, $s2 # incrementing location to draw
			add $t5, $zero, $s2 # stores the location to store into data
			li $t4, 0x10009000 # value for location check
			sub $t4, $t4, 4
			move $t8, $ra #ra sub for sub function
		mainRow2Car:
			beq $t1, $t2, endRow2Car
			sle $t6, $t3, $t4
			beq $t6, $1, altRow2Car
			beq $t6, $0, regRow2Car
		regRow2Car:
			add $t5, $t3, 0#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 384($t3)
			add $s4, $s4, 4 #increment to next address
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow2Car
		altRow2Car:
			add $t5, $t3, 128#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, 128($t3)
			add $t5, $t3,256#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 384($t3)
			add $t5, $t3, 512#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 512($t3)
			add $s4, $s4, 4 #increment to next address
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow2Car
		endRow2Car:
			jr $t8
			
	drawRow3Car:	#8x4 size
		setupRow3Car:
			li $s6, 0xff0000
			add $t1, $zero, $zero # i in the loop
			add $t2, $zero, 8
			add $t3, $zero, $s2 # incrementing location to draw
			add $t5, $zero, $s2 # stores the location to store into data
			li $t4, 0x10009200 #setup the part here we have to go shift
			add $t4, $t4, 128
			move $t8, $ra #ra sub for sub function
		mainRow3Car:
			beq $t1, $t2, endRow3Car
			sle $t6, $t4, $t3
			beq $t6, $1, altRow3Car
			beq $t6, $0, regRow3Car
		regRow3Car:
			add $t5, $t3, 0#get display location of pizel drawn
			sw $t5, 0($s4)
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4)
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 384($t3)
			add $s4, $s4, 4
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow3Car
		altRow3Car:
			sub $t5, $t3, 128#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, -128($t3)
			add $t5, $t3, 0#get display location of pizel drawn
			add $s4, $s4, 4#increment to next address
			sw $t5, 0($s4)
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 256($t3)
			add $s4, $s4, 4
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow3Car
		endRow3Car:
			jr $t8
	drawLogs:
		move $t9, $ra
		lw $s3, log3Location
		la $s4, log3Data
		jal drawRow1Log
		la $s4, log4Data
		lw $s3, log4Location
		jal drawRow1Log
		la $s4, log1Data
		lw $s3, log1Location
		jal drawRow2Log
		la $s4, log2Data
		lw $s3, log2Location
		jal drawRow2Log
		la $s4, log5Data
		lw $s3, log5Location
		jal drawRow3Log
		la $s4, log6Data
		lw $s3, log6Location
		jal drawRow3Log
		jr $t9
		
	drawRow3Log:	#8x4 size
		setupRow3Log:
			li $s6, 0x80471c
			add $t1, $zero, $zero # i in the loop
			add $t2, $zero, 8
			add $t3, $zero, $s3 # incrementing location to draw
			add $t5, $zero, $s3 # stores the location to store into data
			li $t4, 0x10008800 # value for location check
			sub $t4, $t4, 4
			move $t8, $ra #ra sub for sub function
		mainRow3Log:
			beq $t1, $t2, endRow3Log
			sle $t6, $t3, $t4
			beq $t6, $1, altRow3Log
			beq $t6, $0, regRow3Log
		regRow3Log:
			add $t5, $t3, 0#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 384($t3)
			add $s4, $s4, 4 #increment to next address
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow3Log
		altRow3Log:
			add $t5, $t3, 128#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, 128($t3)
			add $t5, $t3,256#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			add $s4, $s4, 4 #increment to next address
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			add $s4, $s4, 4 #increment to next address
			sw $s6, 384($t3)
			add $t5, $t3, 512#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 512($t3)
			add $s4, $s4, 4 #increment to next address
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow3Log
		endRow3Log:
			jr $t8
			
	drawRow2Log:	#8x4 size
		setupRow2Log:
			li $s6, 0x80471c
			add $t1, $zero, $zero # i in the loop
			add $t2, $zero, 8
			add $t3, $zero, $s3 # incrementing location to draw
			add $t5, $zero, $s3 # stores the location to store into data
			li $t4, 0x10008600 #setup the part here we have to go shift
			add $t4, $t4, 128
			move $t8, $ra #ra sub for sub function
		mainRow2Log:
			beq $t1, $t2, endRow2Log
			sle $t6, $t4, $t3
			beq $t6, $1, altRow2Log
			beq $t6, $0, regRow2Log
		regRow2Log:
			add $t5, $t3, 0#get display location of pizel drawn
			sw $t5, 0($s4)
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4)
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 384($t3)
			add $s4, $s4, 4
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow2Log
		altRow2Log:
			sub $t5, $t3, 128#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, -128($t3)
			add $t5, $t3, 0#get display location of pizel drawn
			add $s4, $s4, 4#increment to next address
			sw $t5, 0($s4)
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4
			sw $t5, 0($s4)
			sw $s6, 256($t3)
			add $s4, $s4, 4
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow2Log
		endRow2Log:
			jr $t8
			
	drawRow1Log:	#8x4 size
		setupRow1Log:
			li $s6, 0x80471c
			add $t1, $zero, $zero # i in the loop
			add $t2, $zero, 8
			add $t3, $zero, $s3 # incrementing location to draw
			add $t5, $zero, $s3 # stores the location to store into data
			li $t4, 0x10008400 # value for location check
			sub $t4, $t4, 4
			move $t8, $ra #ra sub for sub function
		mainRow1Log:
			beq $t1, $t2, endRow1Log
			sle $t6, $t3, $t4
			beq $t6, $1, altRow1Log
			beq $t6, $0, regRow1Log
		regRow1Log:
			add $t5, $t3, 0#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, 0($t3)
			add $t5, $t3, 128#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 128($t3)
			add $t5, $t3, 256#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 384($t3)
			add $s4, $s4, 4 #increment to next address
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow1Log
		altRow1Log:
			add $t5, $t3, 128#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			sw $s6, 128($t3)
			add $t5, $t3,256#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			add $s4, $s4, 4 #increment to next address
			sw $s6, 256($t3)
			add $t5, $t3, 384#get display location of pizel drawn
			sw $t5, 0($s4) # save in address
			add $s4, $s4, 4 #increment to next address
			sw $s6, 384($t3)
			add $t5, $t3, 512#get display location of pizel drawn
			add $s4, $s4, 4 #increment to next address
			sw $t5, 0($s4) # save in address
			sw $s6, 512($t3)
			add $s4, $s4, 4 #increment to next address
			add $t3, $t3, 4
			add $t1, $t1, 1
			j mainRow1Log
		endRow1Log:
			jr $t8
	
	moveEntities:	
			setupMoveEnt:
				move $t9, $ra #stores our RA because we are calling sub functions
				#Check to see which ones should move
			mainMoveEnt:
				lw $t0, carRow1ToMove
				lw $t1, carRow1CurM
				beq $t0, $t1, moveCarRow1
				lw $t0, carRow2ToMove
				lw $t1, carRow2CurM
				beq $t0, $t1, moveCarRow2
				lw $t0, carRow3ToMove
				lw $t1, carRow3CurM
				beq $t0, $t1, moveCarRow3
				lw $t0, logRow1ToMove
				lw $t1, logRow1CurM
				beq $t0, $t1, moveLogRow1
				lw $t0, logRow2ToMove
				lw $t1, logRow2CurM
				beq $t0, $t1, moveLogRow2
				lw $t0, logRow3ToMove
				lw $t1, logRow3CurM
				beq $t0, $t1, moveLogRow3
				#Increment all CurMs
				la $a0, carRow1CurM #get address
				lw $a1, carRow1CurM
				add $a1, $a1, 1
				sw $a1, 0($a0) #save
				la $a0, carRow2CurM #get address
				lw $a1, carRow2CurM
				add $a1, $a1, 1
				sw $a1, 0($a0) #save
				la $a0, carRow3CurM #get address
				lw $a1, carRow3CurM
				add $a1, $a1, 1
				sw $a1, 0($a0) #save
				la $a0, logRow1CurM #get address
				lw $a1, logRow1CurM
				add $a1, $a1, 1
				sw $a1, 0($a0) #save
				la $a0, logRow2CurM #get address
				lw $a1, logRow2CurM
				add $a1, $a1, 1
				sw $a1, 0($a0) #save
				la $a0, logRow3CurM #get address
				lw $a1, logRow3CurM
				add $a1, $a1, 1
				sw $a1, 0($a0) #save
				jr $t9
			moveCarRow1:
				jal moveCar1
				jal moveCar2
				la $a0, carRow1CurM #get address
				li $a1, 0
				sw $a1, 0($a0) #save
				j mainMoveEnt
			moveCarRow2:
				jal moveCar3
				jal moveCar4
				la $a0, carRow2CurM #get address
				li $a1, 0
				sw $a1, 0($a0) #save
				j mainMoveEnt
			moveCarRow3:
				jal moveCar5
				jal moveCar6
				la $a0, carRow3CurM #get address
				li $a1, 0
				sw $a1, 0($a0) #save
				j mainMoveEnt
			moveLogRow1:
				jal moveLog3
				jal moveLog4
				la $a0, logRow1CurM #get address
				li $a1, 0
				sw $a1, 0($a0) #save
				j mainMoveEnt
			moveLogRow2:
				jal moveLog1
				jal moveLog2
				la $a0, logRow2CurM #get address
				li $a1, 0
				sw $a1, 0($a0) #save
				j mainMoveEnt
			moveLogRow3:
				jal moveLog5
				jal moveLog6
				la $a0, logRow3CurM #get address
				li $a1, 0
				sw $a1, 0($a0) #save
				j mainMoveEnt
			
	
	moveCar1:
			la $a0, car1Location #get address
			lw $a1, car1Location
			move $t8, $ra
			li $a2, 0x10008E00 #comparison value to original row
			add $a2, $a2, 128
			add $a1, $a1, 4
			sle $t0, $a2, $a1
			beq $t0, $1, resetCar1
			sw $a1, 0($a0) #save
			jr $t8
			resetCar1:
				lw $a0, car1Location
				la $a0, car1Location #get address
				li $a1, 0x10008E00
				sw $a1, 0($a0) #save
				jr $ra
			
	moveCar2:
			la $a0, car2Location #get address
			lw $a1, car2Location
			move $t8, $ra
			li $a2, 0x10008E00 #comparison value to original row
			add $a2, $a2, 128
			add $a1, $a1, 4
			sle $t0, $a2, $a1
			beq $t0, $1, resetCar2
			sw $a1, 0($a0) #save
			jr $t8
			resetCar2:
				lw $a0, car2Location
				la $a0, car2Location #get address
				li $a1, 0x10008E00
				sw $a1, 0($a0) #save
				jr $ra
			
	moveCar3:
			la $a0, car3Location #get address
			lw $a1, car3Location
			move $t8, $ra
			li $a2, 0x10009000 #comparison value to original row
			sub $a2, $a2, 128
			sub $a1, $a1, 4
			sle $t0, $a1, $a2
			beq $t0, $1, resetCar3
			sw $a1, 0($a0) #save
			jr $t8
			resetCar3:
				lw $a0, car3Location
				la $a0, car3Location #get address
				li $a1, 0x10009000
				sw $a1, 0($a0) #save
				jr $ra
			
	moveCar4:
			la $a0, car4Location #get address
			lw $a1, car4Location
			move $t8, $ra
			li $a2, 0x10009000 #comparison value to original row
			sub $a2, $a2, 128
			sub $a1, $a1, 4
			sle $t0, $a1, $a2
			beq $t0, $1, resetCar4
			sw $a1, 0($a0) #save
			jr $t8
			resetCar4:
				lw $a0, car4Location
				la $a0, car4Location #get address
				li $a1, 0x10009000
				sw $a1, 0($a0) #save
				jr $ra
				
	moveCar5:
			la $a0, car5Location #get address
			lw $a1, car5Location
			move $t8, $ra
			li $a2, 0x10009200 #comparison value to original row
			add $a2, $a2, 128
			add $a1, $a1, 4
			sle $t0, $a2, $a1
			beq $t0, $1, resetCar5
			sw $a1, 0($a0) #save
			jr $t8
			resetCar5:
				lw $a0, car5Location
				la $a0, car5Location #get address
				li $a1, 0x10009200
				sw $a1, 0($a0) #save
				jr $ra
			
	moveCar6:
			la $a0, car6Location #get address
			lw $a1, car6Location
			move $t8, $ra
			li $a2, 0x10009200 #comparison value to original row
			add $a2, $a2, 128
			add $a1, $a1, 4
			sle $t0, $a2, $a1
			beq $t0, $1, resetCar6
			sw $a1, 0($a0) #save
			jr $t8
			resetCar6:
				lw $a0, car6Location
				la $a0, car6Location #get address
				li $a1, 0x10009200
				sw $a1, 0($a0) #save
				jr $ra
			
			
	moveLog1:
			la $a0, log1Location #get address
			lw $a1, log1Location
			move $t8, $ra
			li $a2, 0x10008600
			add $a2, $a2, 128
			add $a1, $a1, 4
			sle $t0, $a2, $a1
			beq $t0, $1, resetLog1
			sw $a1, 0($a0) #save
			jr $t8
			resetLog1:
				lw $a0, log1Location
				la $a0, log1Location #get address
				li $a1, 0x10008600
				sw $a1, 0($a0) #save
				jr $ra
			
	moveLog2:
			la $a0, log2Location #get address
			lw $a1, log2Location
			move $t8, $ra
			li $a2, 0x10008600
			add $a2, $a2, 128
			add $a1, $a1, 4
			sle $t0, $a2, $a1
			beq $t0, $1, resetLog2
			sw $a1, 0($a0) #save
			jr $t8
			resetLog2:
				lw $a0, log2Location
				la $a0, log2Location #get address
				li $a1, 0x10008600
				sw $a1, 0($a0) #save
				jr $ra
			
	moveLog3:
			la $a0, log3Location #get address
			lw $a1, log3Location
			move $t8, $ra
			li $a2, 0x10008460
			sub $a2, $a2, 128
			sub $a1, $a1, 4
			sle $t0, $a1, $a2
			beq $t0, $1, resetLog3
			sw $a1, 0($a0) #save
			jr $t8
			resetLog3:
				lw $a0, log3Location
				la $a0, log3Location #get address
				li $a1, 0x10008460
				sw $a1, 0($a0) #save
				jr $ra
			
	moveLog4:
			la $a0, log4Location #get address
			lw $a1, log4Location
			move $t8, $ra
			li $a2, 0x10008460
			sub $a2, $a2, 128
			sub $a1, $a1, 4
			sle $t0, $a1, $a2
			beq $t0, $1, resetLog4
			sw $a1, 0($a0) #save
			jr $t8
			resetLog4:
				lw $a0, log4Location
				la $a0, log4Location #get address
				li $a1, 0x10008460
				sw $a1, 0($a0) #save
				jr $ra
	moveLog5:
			la $a0, log5Location #get address
			lw $a1, log5Location
			move $t8, $ra
			li $a2, 0x10008860
			sub $a2, $a2, 128
			sub $a1, $a1, 4
			sle $t0, $a1, $a2
			beq $t0, $1, resetLog5
			sw $a1, 0($a0) #save
			jr $t8
			resetLog5:
				lw $a0, log5Location
				la $a0, log5Location #get address
				li $a1, 0x10008860
				sw $a1, 0($a0) #save
				jr $ra
			
	moveLog6:
			la $a0, log6Location #get address
			lw $a1, log6Location
			move $t8, $ra
			li $a2, 0x10008860
			sub $a2, $a2, 128
			sub $a1, $a1, 4
			sle $t0, $a1, $a2
			beq $t0, $1, resetLog6
			sw $a1, 0($a0) #save
			jr $t8
			resetLog6:
				lw $a0, log6Location
				la $a0, log6Location #get address
				li $a1, 0x10008860
				sw $a1, 0($a0) #save
				jr $ra

#Draw Letters
	drawG:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 268($t0)
		sw $s6, 384($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		sw $s6, 396($t0)
		jr $ra
	
	drawA:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 12($t0)
		sw $s6, 128($t0)
		sw $s6, 140($t0)
		sw $s6, 256($t0)
		sw $s6, 260($t0)
		sw $s6, 264($t0)
		sw $s6, 268($t0)
		sw $s6, 384($t0)
		sw $s6, 396($t0)
		jr $ra
		
	drawM:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 384($t0)
		sw $s6, 12($t0)
		sw $s6, 140($t0)
		sw $s6, 268($t0)
		sw $s6, 396($t0)
		sw $s6, 8($t0)
		sw $s6, 136($t0)
		sw $s6, 132($t0)
		sw $s6, 260($t0)
		jr $ra
	
	drawE:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 384($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 12($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		sw $s6, 396($t0)
		sw $s6, 132($t0)
		jr $ra
		
	drawO:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 384($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 12($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		sw $s6, 396($t0)
		sw $s6, 140($t0)
		sw $s6, 268($t0)
		jr $ra
	
	drawV:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		sw $s6, 140($t0)
		sw $s6, 268($t0)
		sw $s6, 12($t0)
		jr $ra
	
	drawR:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 384($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 12($t0)
		sw $s6, 392($t0)
		sw $s6, 396($t0)
		sw $s6, 140($t0)
		sw $s6, 260($t0)
		sw $s6, 264($t0)
		jr $ra
	
	drawP:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 384($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 12($t0)
		sw $s6, 140($t0)
		sw $s6, 260($t0)
		sw $s6, 264($t0)
		sw $s6, 268($t0)
		jr $ra
		
	drawS:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 384($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 12($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		sw $s6, 396($t0)
		sw $s6, 268($t0)
		sw $s6, 132($t0)
		sw $s6, 264($t0)
		jr $ra
	
	drawT:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 12($t0)
		sw $s6, 132($t0)
		sw $s6, 136($t0)
		sw $s6, 260($t0)
		sw $s6, 264($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		jr $ra
	
	drawY:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 12($t0)
		sw $s6, 128($t0)
		sw $s6, 140($t0)
		sw $s6, 132($t0)
		sw $s6, 136($t0)
		sw $s6, 260($t0)
		sw $s6, 264($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		jr $ra
		
	drawU:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		sw $s6, 140($t0)
		sw $s6, 268($t0)
		sw $s6, 12($t0)
		sw $s6, 384($t0)
		sw $s6, 396($t0)
		jr $ra

	drawD:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 128($t0)
		sw $s6, 256($t0)
		sw $s6, 384($t0)
		sw $s6, 4($t0)
		sw $s6, 8($t0)
		sw $s6, 388($t0)
		sw $s6, 392($t0)
		sw $s6, 140($t0)
		sw $s6, 268($t0)
		jr $ra

	drawN:
		add $t0, $zero, $s1
		sw $s6, 0($t0)
		sw $s6, 12($t0)
		sw $s6, 128($t0)
		sw $s6, 140($t0)
		sw $s6, 256($t0)
		sw $s6, 268($t0)
		sw $s6, 384($t0)
		sw $s6, 396($t0)
		sw $s6, 132($t0)
		sw $s6, 264($t0)
		jr $ra
