.data
fileIn:		.asciiz "input.txt"
fileOut:	.asciiz	"output.txt"
newLine:	.asciiz "\n"
space:		.asciiz " - "
separator:	.asciiz	"Escriba el separador de sus frases: "
letra:		.word 	0
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
	jal leerSeparador
	jal leerArchivo
	jal contarFrases
	jal construirArreglo
	#jal pruebaSort
	jal mergesort
	jal imprimirArreglo
	#jal imprimirArchivo
	
	done
	
	
leerSeparador:
	printStr separator
	li $v0, 12				# Directiva para ingrsar un caracter
	syscall
	move $t2, $v0				# Guardar separador ingresado
	move $s6, $t2
	printLn
	
	jr $ra	
	
leerArchivo:

	# Abrir archivo
	li $v0, 13           			# Directiva para abrir archivo
    	la $a0, fileIn    			# $a0 = filePath // sentences.txt
    	li $a1, 0           	
    	syscall
    	move $s0,$v0        			# $s0 = file descriptor
	
	# Leer archivo
	li $v0, 14				# Directiva para leer archivo
	move $a0, $s0				# $a0 = $s0
	la $a1, buffer  			# Buffer con el contenido del archivo
	la $a2, 5120				# Tamano maximo del buffer
	syscall	
	add $t0, $zero, $v0     		# Guarda el numero de caracteres leidos en $t0
	move	$s3, $t0
	
	
	# Cerrar archivo
    	li $v0, 16         			# close_file syscall code
    	move $a0,$s0     			# file descriptor to close
    	syscall	
	
	#lb $t2, separator			# set separator
	jr $ra
	
contarFrases:
	
	add $t9, $zero, $a1			# Save buffer address in j
	addi $t1, $zero, 0			# i = 0;
	addi $t4, $zero, 0			# SentenceCount = 0;
	addi $t5, $zero, 1			# Aux = 1
	
	WHILE_1:

		beq 	$t1, $t0, EXIT_1	# while (i != buffer.length)
		bgt 	$t1, $t0, EXIT_1	# while (i < buffer.length)
		lb 	$t3, 0($t9)		# set char content

  		bne $t3, $t2, L1		# branch if !(char[j] == separator)
  		beq $t5, 1, L1			# branch if (aux == 1)
  		addi $t5, $zero, 1		# Aux = 1
  		
  		L1:
  		beq $t3, $t2, L2		# branch if (char[j] == separator)
  		bne $t5, 1, L2			# branch if (aux != 1)
  		addi $t5, $zero, 0		# Aux = 0
  		addi $t4, $t4, 1       		# sentenceCount++;
		L2:
		addi $t1, $t1, 1        	# i++;
		addi $t9, $t9, 1		# j++;
		j WHILE_1
	
		
	EXIT_1:
		
	add $t8, $zero, $t4			# saving n sentences
	jr $ra
	
construirArreglo:

	asignarEspacio $t4
	addi $t6, $v0, 0			# Using a stack
	la $s7, ($t6)
	
	addi $sp, $sp, -4			# Adjust stack pointer
	sw $t6, 0($sp)
	add $t9, $zero, $a1			# Save Buffer address in j
	addi $t1, $zero, 0			# i = 0;
	addi $t5, $zero, 1			# Aux = 1;
	
	WHILE_2:
	
		beq 	$t1, $t0, EXIT_2	# while (i != buffer.length)
		bgt 	$t1, $t0, EXIT_2	# while (i < buffer.length)
		lb 	$t3, 0($t9)		# set char content

  		bne $t3, $t2, L3		# branch if !(char[j] == separator)
  		beq $t5, 1, L3			# branch if (aux == 1)
  		addi $t5, $zero, 1		# Aux = 1
  		
  		L3:
  		beq $t3, $t2, L4		# branch if (char[j] == separator)
  		bne $t5, 1, L4			# branch if (aux != 1)
  		addi $t5, $zero, 0		# Aux = 0
  		printChar $t9			# print(char[j]);\
  		printSpace
  		printInt $t9
  		printLn				# printLn();
  		sw $t9, 0($t6)			# Save t9 address in a  arr()
  		addi $t6, $t6, 4		
		L4:
		addi $t1, $t1, 1        	# i++;
		addi $t9, $t9, 1		# j++;
		
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
	add	$t2, $zero, $t0
	add	$t3, $zero, $t1
	lb	$t0, 0($t2)	# Load the first half position value
	lb	$t1, 0($t3)	# Load the second half position value
		
	beq	$s0, $s1, EXIT_4
	
	WHILE_4:
		
		bne	$t1, $t0, EXIT_4 # while 
		addi	$t2, $t2, 1	# i++;
		addi 	$t3, $t3, 1	# j++;
		lb	$t0, 0($t2)	# Load the first half position value
		lb	$t1, 0($t3)	# Load the second half position value
		j WHILE_4
		
	EXIT_4:	
	
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

	# Abrir archivo
	li $v0, 13           		# Directiva para abrir archivo
    	la $a0, fileOut			# $a0 = filePath // sentences.txt
    	li $a1, 1
    	li $a2, 0        	
    	syscall
    	move $s0,$v0        		# $s0 = file descriptor

	# En $t6 tengo la dirección de mi vector de direcciones, necesito uno para caracteres
	addi 	$t1, $zero, 0		# i = 0;
	addi 	$t2, $zero, 0		# j = 0;
	addi 	$t3, $t4, 0		# $t3 = longitud palabras ordenadas
	add 	$t6, $zero, $s7		# $t6 = direccion de primeras ordenadas
	add 	$t8, $zero, $s6		# $t8 = separador
	
	WHILE_3:
	
		beq 	$t1, $t3, EXIT_3	# while (i != n_frases)
		lw 	$t7, 0($t6)		# cargar en t7 la primera letra de la primera ordenada
		
		WHILE_5:
			
			beq 	$t2, $s3, EXIT_5	# while (i != buffer.length)
			lb 	$t4, 0($t7)		# cargar en t4 el primer byte
  			la 	$t5, letra		# cargar en t5 la direccion de frases
  			
  			beq 	$t4, $t8, L5		# branch if (char[j] == separator)
  			printChar $t7
  			
  			# Escribir caracter en archivo
  			sb	$t4, 0($t5)
  			li 	$v0, 15
			move 	$a0, $s0
			la 	$a1, 0($t5)
			li 	$a2, 1
			syscall
			
			addi 	$t2, $t2, 1        	# j++;
			addi 	$t7, $t7, 1		# k++;
			j WHILE_5
			
			L5:
			printLn
			
			# Escribir salto de linea en archivo
			li	$t4, 10
			sb	$t4, 0($t5)
  			li 	$v0, 15
			move 	$a0, $s0
			la 	$a1, 0($t5)
			li 	$a2, 1
			syscall
		
		EXIT_5:
		 
		addi $t1, $t1, 1	# i++;
		addi $t6, $t6, 4 	# $t6 = $t6 + 4;;
		j WHILE_3
		
	EXIT_3:		
	  
	# Cerrar archivo
    	li $v0, 16         			# close_file syscall code
    	move $a0,$s0     			# file descriptor to close
    	syscall	
	jr $ra

	
	
	
	
