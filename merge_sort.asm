.data
fileIn:		.asciiz "input.txt"
fileOut:	.asciiz	"output.txt"
newLine:	.asciiz	"\n"
separator:	.asciiz	"Escriba el separador de sus frases: "
letra:		.word 	0
.align 2
buffer:         .space 5120

# Declaracion de Macros
.macro printLn	# Macro para salto de línea
  li $v0, 4		
  la $a0, newLine
  syscall
.end_macro 
.macro printStr (%line) # Macro para escribir un string
  li $v0, 4		
  la $a0, %line
  syscall
.end_macro 
.macro asignarEspacio (%n_frases) # Macro para reservar espacio en memoria
  li $v0, 9	
  la $a0, (%n_frases)
  syscall
.end_macro 
.macro done	#Macro para finalizar el programa
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
	jal mergesort
	jal escribirArchivo
	
	done
	
	
leerSeparador:
	printStr separator
	li 	$v0, 12				# Directiva para ingresar un caracter
	syscall
	move 	$t2, $v0			# Guardar el separador ingresado
	move 	$s6, $t2
	printLn
	
	jr 	$ra	
	
leerArchivo:

	# Abrir archivo
	li 	$v0, 13           	# Directiva para abrir archivo
    	la 	$a0, fileIn    		# $a0 = fileIn // sentences.txt
    	li 	$a1, 0           		
    	syscall
    	move 	$s0,$v0        		# $s0 = descriptor de archivo
	
	# Leer archivo
	li 	$v0, 14			# Directiva para leer archivo
	move 	$a0, $s0		# $a0 = $s0
	la 	$a1, buffer  		# Buffer con el contenido del archivo
	la 	$a2, 5120		# Tamano maximo del buffer
	syscall	
	add 	$t0, $zero, $v0     	# Guarda el numero de caracteres leidos en $t0
	move	$s3, $t0
	
	
	# Cerrar archivo
    	li 	$v0, 16         	# Directiva para cerrar archivo
    	move 	$a0,$s0     		# $a0 = descriptor de archivo
    	syscall	
	
	jr 	$ra
	
# Procedimiento para contar el número de frases
contarFrases:
	
	# Inicialización de variables
	add 	$t9, $zero, $a1		# j = dirección inicial del Buffer
	addi 	$t1, $zero, 0		# i = 0;
	addi 	$t4, $zero, 0		# SentenceCount = 0;
	addi 	$t5, $zero, 1		# Aux = 1;
	
	WHILE_1:

		beq 	$t1, $t0, EXIT_1	# while (i != buffer.length)
		lb 	$t3, 0($t9)		# $t3 = buffer[j]; // primer caracter del archivo

  		bne 	$t3, $t2, L1		# branch if !(char[j] == separator)
  		beq 	$t5, 1, L1		# branch if (aux == 1)
  		addi 	$t5, $zero, 1		# Aux = 1;
  		
  		L1:
  		beq 	$t3, $t2, L2		# branch if (char[j] == separator)
  		bne 	$t5, 1, L2		# branch if (aux != 1)
  		addi 	$t5, $zero, 0		# Aux = 0;
  		addi 	$t4, $t4, 1     	# sentenceCount++;
		L2:
		addi 	$t1, $t1, 1     	# i++;
		addi 	$t9, $t9, 1		# j++;
		j 	WHILE_1
	
	EXIT_1:
		
	add 	$t8, $zero, $t4		# saving n sentences
	jr 	$ra

# Procedimiento para almacenar el la dirección del primer caracter de cada frase en un espacio
# en un espacio asignado en memoria, cuyo tamaño es la cantidad de frases que se contaron en 
# el procedimiento anterior.
construirArreglo:

	asignarEspacio $t4		# Macro para asignar espacio $t4 en memoria
	addi 	$t6, $v0, 0		# Guardar la dirección del espacio asignado en $t6
	la 	$s7, ($t6)		# Guardarla también en $s7
	
	addi 	$sp, $sp, -4		# Ajustar apuntar de la pila
	sw 	$t6, 0($sp)		# Almacenar en la pila direccion inicial del espacio asignado
	add 	$t9, $zero, $a1		# j = dirección inicial del Buffer;
	addi 	$t1, $zero, 0		# i = 0;
	addi 	$t5, $zero, 1		# Aux = 1;
	
	WHILE_2:
	
		beq 	$t1, $t0, EXIT_2	# while (i != buffer.length)
		lb 	$t3, 0($t9)		# $t3 = buffer[j]; // primer caracter del archivo

  		bne 	$t3, $t2, L3		# branch if !(char[j] == separator)
  		beq 	$t5, 1, L3		# branch if (aux == 1)
  		addi 	$t5, $zero, 1		# Aux = 1;
  		
  		L3:
  		beq 	$t3, $t2, L4		# branch if (char[j] == separator)
  		bne 	$t5, 1, L4		# branch if (aux != 1)
  		addi 	$t5, $zero, 0		# Aux = 0;			
  		sw	$t9, 0($t6)		# Guardar la dirección en t9 en el espacio asignado
  		addi 	$t6, $t6, 4		# Avanza a la siguiente posición del espacio asignado
		L4:
		addi 	$t1, $t1, 1        	# i++;
		addi 	$t9, $t9, 1		# j++;
		
		j 	WHILE_2
	
	EXIT_2:
	
	la 	$a1, ($t6)		# Carga en a1, la dirección final del espacio asignado
	lw 	$t6, 0($sp)		# Recupera de la pila la dirección inicial
	la 	$a0, ($t6)		# Carga en a0, la dirección inicial del espacio asignado
	jr 	$ra
	
# Procedimiento con el que comienza el ordenamiento merge sort.
mergesort:

	addi	$sp, $sp, -16		# Ajusta el apuntador de la pila
	sw	$ra, 0($sp)		# Almacena la dirección de retorno en la pila
	sw	$a0, 4($sp)		# Almacena la dirección de inicio del arreglo en la pila
	sw	$a1, 8($sp)		# Almacena la dirección de fin del arreglo en la pila
	
	sub 	$t0, $a1, $a0		# Calcular diferencia entre dirección de inicio y de fin

	ble	$t0, 4, mergesortend	# Si el arreglo tiene un solo elemento, retornar
	
	srl	$t0, $t0, 3		# Dividir el tamaño del arreglo por 8 para reducir el número de elementos a la mitad
	sll	$t0, $t0, 2		# Multiplicar el número por 4 para obtener el tamaño de la mitad del arreglo
	add	$a1, $a0, $t0		# Calcular el punto de acceso medio al arreglo
	sw	$a1, 12($sp)		# Almacenar el punto medio de acceso en al pila
	
	jal	mergesort		# Llamarse recursivamente para la primera mitad del arreglo
	
	lw	$a0, 12($sp)		# Cargar el punto medio de acceso de la pila
	lw	$a1, 8($sp)		# Cargar la direccion fin del arreglo de la pila
	
	jal	mergesort		# Llamarse recursivamente para la segunda mitad del arreglo
	
	lw	$a0, 4($sp)		# Cargar la direccion de inicio de la pila
	lw	$a1, 12($sp)		# Cargar el punto medio de acceso de la pila
	lw	$a2, 8($sp)		# Cargar la direccion de fin de la pila
	
	jal	merge			# Aplicar "merge" a las dos mitades del arreglo
	
mergesortend:				

	lw	$ra, 0($sp)		# Cargar la dirección de retorno de la pila, la dirección de "mergesort"
	addi	$sp, $sp, 16		# Ajustar el apuntador
	jr	$ra			

# Procedimiento merge para las mitades del arreglo
merge:
	addi	$sp, $sp, -16		# Ajustar el apuntador
	sw	$ra, 0($sp)		# Almacena la dirección de retorno en la pila
	sw	$a0, 4($sp)		# Almacena la dirección de inicio del arreglo en la pila
	sw	$a1, 8($sp)		# Almacena el punto medio de acceso del arreglo en la pila
	sw	$a2, 12($sp)		# Almacena la dirección de fin del arreglo en la pila
	
	move	$s0, $a0		# Copia de la dirección de la primera mitad
	move	$s1, $a1		# Copia de la dirección de la segunda mitad
	
mergeloop:

	lw	$t0, 0($s0)		# Cargar la dirección de la primera mitad
	lw	$t1, 0($s1)		# Cargar la dirección de la segunda mitad
	add	$t2, $zero, $t0
	add	$t3, $zero, $t1
	lb	$t0, 0($t2)		# Cargar el valor del elemento de la primera mitad
	lb	$t1, 0($t3)		# Cargar el valor del elemento de la segunda mitad
		
	beq	$s0, $s1, EXIT_4	# Si son iguales s0 y s1, se compararía un elemento consigo mismo
	
	# Ciclo para avanzar caracter de una palabra en caso de que la primera sea igual
	# e.j.: abeja < avion
	WHILE_4:
		
		bne	$t1, $t0, EXIT_4 	# while s0 = s1
		addi	$t2, $t2, 1		# i++;
		addi 	$t3, $t3, 1		# j++;
		lb	$t0, 0($t2)		# Cargar el valor del siguiente caracter del elemento de la primera mitad
		lb	$t1, 0($t3)		# Cargar el valor del siguiente caracter del elemento de la segunda mitad
		j 	WHILE_4
		
	EXIT_4:	
	
	bgt	$t1, $t0, noshift	# Si el menor valor ya está primero, no hay que moverlo
	
	move	$a0, $s1		# Cargar argumento con el elemento a mover
	move	$a1, $s0		# Cargar argumento con la dirección a donde mover el elemento
	jal	shift			# Cambiar de posición el elemento
	
	addi	$s1, $s1, 4		# Aumentar el indice de la segunda mitad
noshift:
	addi	$s0, $s0, 4		# Aumentar el indice de la primera mitad
	
	lw	$a2, 12($sp)		# Recargar la dirección de fin del arreglo de la pila
	bge	$s0, $a2, mergeloopend	# Fin del loop cuando ambas mitades estan vacias
	bge	$s1, $a2, mergeloopend	# =============================================
	b	mergeloop
	
mergeloopend:
	
	lw	$ra, 0($sp)		# Carga la dirección de retorno de la pila, la dirección de "merge"
	addi	$sp, $sp, 16		# Ajusta el apuntador
	jr 	$ra		

shift:
	li	$t0, 10
	ble	$a0, $a1, shiftend	# Si se está en la posición destino, no hay que mover
	addi	$t6, $a0, -4		# Encontrar la dirección anterior en el arreglo
	lw	$t7, 0($a0)		# Cargar el apuntador actual
	lw	$t8, 0($t6)		# Cargar el apuntador previo
	sw	$t7, 0($t6)		# Guardar el apuntador actual a la direccion previa
	sw	$t8, 0($a0)		# Guardar el apuntador previo a la direccion actual
	move	$a0, $t6		# Mover la posición actual, de nuevo a a0
	b 	shift			
shiftend:
	jr	$ra			
	
escribirArchivo:

	# Abrir archivo
	li 	$v0, 13           	# Directiva para abrir archivo
    	la 	$a0, fileOut		# $a0 = filePath // sentences.txt
    	li 	$a1, 1
    	li 	$a2, 0        	
    	syscall
    	move 	$s0,$v0        		# $s0 = descriptor de archivo

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
  			
  			# Escribir caracter en archivo
  			sb	$t4, 0($t5)
  			li 	$v0, 15
			move 	$a0, $s0
			la 	$a1, 0($t5)
			li 	$a2, 1
			syscall
			
			addi 	$t2, $t2, 1        	# j++;
			addi 	$t7, $t7, 1		# k++;
			j 	WHILE_5
			
			L5:
			
			# Escribir salto de linea en archivo
			li	$t4, 10
			sb	$t4, 0($t5)
  			li 	$v0, 15
			move 	$a0, $s0
			la 	$a1, 0($t5)
			li 	$a2, 1
			syscall
		
		EXIT_5:
		 
		addi 	$t1, $t1, 1	# i++;
		addi 	$t6, $t6, 4 	# $t6 = $t6 + 4;;
		j 	WHILE_3
		
	EXIT_3:		
	  
	# Cerrar archivo
    	li 	$v0, 16         	# Directiva para cerrar archivo
    	move 	$a0,$s0     		# $a0 = descriptor de archivo
    	syscall	
	jr 	$ra

	
	
	
	
