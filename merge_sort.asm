.data
fileIn:		.asciiz "sentences.txt"
newLine:	.asciiz "\n"
space:		.asciiz " - "
nChars:		.asciiz "Numero de caracteres: "
nSentences:	.asciiz "Numero de frases: "
fileContent:	.asciiz "Contenido de archivo: "
firstLetter:	.asciiz "Primera letra de cada frase: "
separator:	.byte   ';'
.align 2
buffer:         .space 5120

# Declaracion de Macros
.macro printLn
  li $v0, 4		
  la $a0, newLine
  syscall
.end_macro 
.macro printSpace
  li $v0, 4		
  la $a0, space
  syscall
.end_macro 
.macro printStr (%line)
  li $v0, 4		
  la $a0, %line
  syscall
.end_macro 
.macro printInt (%i)
  li $v0, 1		
  move $a0, %i
  syscall
.end_macro 
.macro printChar (%c)
  lb $a0, (%c)
  li $v0, 11
  syscall
.end_macro 
.macro asignarEspacio (%n_frases)
  li $v0, 9	
  la $a0, (%n_frases)
  syscall
.end_macro 
.macro done
  li $v0, 10
  syscall
.end_macro 

# Cuerpo del Programa
.text 

main:
	jal leerArchivo
	jal contarFrases
	jal construirArreglo
	#jal pruebaSort
	jal mergesort
	jal imprimirArreglo
	
	done
	
leerArchivo:

	# Abrir archivo
	li $v0, 13           			# Directiva para abrir archivo
    	la $a0, fileIn    			# $a0 = filePath // sentences.txt
    	li $a1, 0           	
    	syscall
    	move $s0,$v0        			# $s0 = file descriptor
	
	# Leer archivo
	li $v0, 14				# Directiva para leer archivo
	move $a0,$s0				# $a0 = $s0
	la $a1, buffer  			# Buffer con el contenido del archivo
	la $a2, 5120				# Tamano maximo del buffer
	syscall	
	add $t0, $zero, $v0     		# Guarda el numero de caracteres leidos en $t0
	
	# Cerrar archivo
    	li $v0, 16         			# close_file syscall code
    	move $a0,$s0      			# file descriptor to close
    	syscall
	
	# Imprimir contenido de archivo
	#printStr fileContent
	#printStr buffer
	
	# Imprimir n de caracteres
	#printLn
	#printStr nChars
	#printInt $t0				# $t0 = buffer.length
	#printLn 	
	
	lb $t2, separator			# set separator
	jr $ra
	
contarFrases:
	
	add $t9, $zero, $a1			# Guarda la direccion del Buffer en j
	addi $t1, $zero, 0			# i = 0;
	addi $t4, $zero, 0			# sentenceCount = 0;
	
	WHILE_1:

		beq $t1, $t0, EXIT_1		# while (i != buffer.length)
		bgt $t1, $t0, EXIT_1		# while (i < buffer.length)
		lb $t3, 0($t9)			# set char content

  		bne $t3, $t2, L1		# branch if !(char[j] == separator)
  		addi $t4, $t4, 1       		# sentenceCount++;
		L1:
		addi $t1, $t1, 1        	# i++;
		addi $t9, $t9, 1		# j++;
		j WHILE_1
		
	EXIT_1:
	
	#printStr nSentences
	#printInt $t4
	#printLn	
	add $t8, $zero, $t4			# Guardando n de frases
	jr $ra
	
construirArreglo:

	#printStr firstLetter
	#printLn
	asignarEspacio $t4
	addi $t6, $v0, 0			# Usar una pila
	la $s7, ($t6)
	
	addi $sp, $sp, -4			# Adjust stack pointer
	sw $t6, 0($sp)
	add $t9, $zero, $a1			# Guarda la direccion del Buffer en j
	addi $t1, $zero, 0			# i = 0;
	addi $t5, $zero, 0			# flag = 0; Se ouede quitar
	
	WHILE_2:
	
		beq $t1, $t0, EXIT_2		# while (i != buffer.length)
		bgt $t1, $t0, EXIT_2		# while (i < buffer.length)
		lb $t3, 0($t9)			# set char content
		beq $t1, $zero, IF2		# if (i == 0)
		bne $t5, 1, END2		# OR !(flag == 1)
	
		IF2:
 	
 			addi $t5, $zero, 0	# flag = 0;
  			printChar $t9		# print(char[j]);\
  			printLn			# printLn();
  			sw $t9, 0($t6)		# Guardar direccion de $t9 en un arr()
  			addi $t6, $t6, 4	# $t4 = $t4 + 4;
  			
		END2:
		
  		bne $t3, $t2, L2	# branch if !(char[j] == separator)
  		addi $t5, $t5, 1        # flag = 1; TRUE
  			
		L2:
		
		addi $t1, $t1, 1        # i++;
		addi $t9, $t9, 1	# j++;
		j WHILE_2
	
	EXIT_2:
	
	printSpace
  	printLn
	
	la $a1, ($t6)
	lw $t6, 0($sp)
	la $a0, ($t6)
	jr $ra
	
mergesort:

	addi	$sp, $sp, -16		# Adjust stack pointer
	sw	$ra, 0($sp)		# Store the return address on the stack
	sw	$a0, 4($sp)		# Store the array start address on the stack
	sw	$a1, 8($sp)		# Store the array end address on the stack
	
	sub 	$t0, $a1, $a0		# Calculate the difference between the start and end address (i.e. number of elements * 4)

	ble	$t0, 4, mergesortend	# If the array only contains a single element, just return
	
	srl	$t0, $t0, 3		# Divide the array size by 8 to half the number of elements (shift right 3 bits)
	sll	$t0, $t0, 2		# Multiple that number by 4 to get half of the array size (shift left 2 bits)
	add	$a1, $a0, $t0		# Calculate the midpoint address of the array
	sw	$a1, 12($sp)		# Store the array midpoint address on the stack
	
	jal	mergesort		# Call recursively on the first half of the array
	
	lw	$a0, 12($sp)		# Load the midpoint address of the array from the stack
	lw	$a1, 8($sp)		# Load the end address of the array from the stack
	
	jal	mergesort		# Call recursively on the second half of the array
	
	lw	$a0, 4($sp)		# Load the array start address from the stack
	lw	$a1, 12($sp)		# Load the array midpoint address from the stack
	lw	$a2, 8($sp)		# Load the array end address from the stack
	
	jal	merge			# Merge the two array halves
	
mergesortend:				

	lw	$ra, 0($sp)		# Load the return address from the stack
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr	$ra			# Return 
	
##
# Merge two sorted, adjacent arrays into one, in-place
#
# @param $a0 First address of first array
# @param $a1 First address of second array
# @param $a2 Last address of second array
##
merge:
	addi	$sp, $sp, -16		# Adjust the stack pointer
	sw	$ra, 0($sp)		# Store the return address on the stack
	sw	$a0, 4($sp)		# Store the start address on the stack
	sw	$a1, 8($sp)		# Store the midpoint address on the stack
	sw	$a2, 12($sp)		# Store the end address on the stack
	
	move	$s0, $a0		# Create a working copy of the first half address
	move	$s1, $a1		# Create a working copy of the second half address
	
mergeloop:

	lw	$t0, 0($s0)		# Load the first half position pointer
	lw	$t1, 0($s1)		# Load the second half position pointer
	lw	$t0, 0($t0)		# Load the first half position value
	lw	$t1, 0($t1)		# Load the second half position value
	
	
	bgt	$t1, $t0, noshift	# If the lower value is already first, don't shift
	
	move	$a0, $s1		# Load the argument for the element to move
	move	$a1, $s0		# Load the argument for the address to move it to
	jal	shift			# Shift the element to the new position 
	
	addi	$s1, $s1, 4		# Increment the second half index
noshift:
	addi	$s0, $s0, 4		# Increment the first half index
	
	lw	$a2, 12($sp)		# Reload the end address
	bge	$s0, $a2, mergeloopend	# End the loop when both halves are empty
	bge	$s1, $a2, mergeloopend	# End the loop when both halves are empty
	b	mergeloop
	
mergeloopend:
	
	lw	$ra, 0($sp)		# Load the return address
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr 	$ra			# Return

##
# Shift an array element to another position, at a lower address
#
# @param $a0 address of element to shift
# @param $a1 destination address of element
##
shift:
	li	$t0, 10
	ble	$a0, $a1, shiftend	# If we are at the location, stop shifting
	addi	$t6, $a0, -4		# Find the previous address in the array
	lw	$t7, 0($a0)		# Get the current pointer
	lw	$t8, 0($t6)		# Get the previous pointer
	sw	$t7, 0($t6)		# Save the current pointer to the previous address
	sw	$t8, 0($a0)		# Save the previous pointer to the current address
	move	$a0, $t6		# Shift the current position back
	b 	shift			# Loop again
shiftend:
	jr	$ra			# Return
	
imprimirArreglo:

	# En $t6 tengo la dirección de mi vector de direcciones, necesito uno para caracteres
	addi $t1, $zero, 0		# i = 0;
	addi $t6, $zero, 268697600
	addi $t8, $zero, 5
	WHILE_3:
	
		beq $t1, $t8, EXIT_3	# while (i != n_frases)
		lw $t2, 0($t6)		
		printChar $t2		
		printSpace
		printInt $t2		# direccion de inicio de
		printLn
		#lb $t3, 0($t2)
		#printInt $t3		# Numero int del caracter
		#printLn
		#printInt $t6
		#printLn
		addi $t1, $t1, 1	# i++;
		addi $t6, $t6, 4 	# $t6 = $t6 + 4;;
		j WHILE_3
	EXIT_3:
	
	jr $ra
	

	
	
