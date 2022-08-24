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
	jal imprimirArreglo
	#jal mergeSort
	#jal escribaArchivo // output.txt
	
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
	printStr fileContent
	printStr buffer
	
	# Imprimir n de caracteres
	printLn
	printStr nChars
	printInt $t0				# $t0 = buffer.length
	printLn 	
	
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
	
	printStr nSentences
	printInt $t4
	printLn	
	add $t8, $zero, $t4			# Guardando n de frases
	jr $ra
	
construirArreglo:

	printStr firstLetter
	printLn
	asignarEspacio $t4
	move $t4, $v0				# Usar una pila
	move $t6, $v0
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
  			#printChar $t9		# print(char[j]);\
  			#printLn		# printLn();
  			sw $t9, 0($t4)		# Guardar direccion de $t9 en un arr()
  			addi $t4, $t4, 4	# $t4 = $t4 + 4;
  			
		END2:
		
  		bne $t3, $t2, L2	# branch if !(char[j] == separator)
  		addi $t5, $t5, 1        # flag = 1; TRUE
  			
		L2:
		
		addi $t1, $t1, 1        # i++;
		addi $t9, $t9, 1	# j++;
		j WHILE_2
	
	EXIT_2:
		
	jr $ra

imprimirArreglo:

	# En $t6 tengo la dirección de mi vector de direcciones, necesito uno para caracteres
	addi $t1, $zero, 0		# i = 0;
	
	WHILE_3:
	
		beq $t1, $t8, EXIT_3	# while (i != n_frases)
		#bgt $t1, $t8, EXIT_3	# while (i < n_frases)
		lw $t2, 0($t6)		
		printChar $t2		
		printSpace
		#printInt $t2		# direccion de inicio de
		#printLn
		lb $t3, 0($t2)
		printInt $t3		# Numero int del caracter
		printLn
		addi $t1, $t1, 1	# i++;
		addi $t6, $t6, 4 	# $t6 = $t6 + 4;;
		j WHILE_3
	EXIT_3:
	
	jr $ra
	

	
	
