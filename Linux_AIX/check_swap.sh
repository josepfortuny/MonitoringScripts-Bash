#!/bin/bash
#
# Detección de la memoria swap disponible de los sistemas operativos Lunix/Unix.
# Escrito por Josep Fortuny Casablancas (jfortunycasablancas@gmail.com)
# Ultima Modificación : 07-08-2019
#
# Metodos de uso: 
#
# ./check_swaps [-c critical] [-w warning]
#
# Descripcion:
#
# Este programa obtiene el tanto por ciento libre de la memoria swap del sistema y  
# la compara con el umbral especificado en los argumentos del programa. Si un 
# umbral es superior al porcentaje libre de la memoria, adapta el mensaje 
# para mostrar de forma clara el estado critico , peligroso o estable de su uso 
# enviando el estado de estos. 
#
#Restricciones:
#	1. El parametro critico ha de ser inferior al parametro peligroso
#	2. Los dos argumentos han de comprender entre 1 y 99
#	3. Los argumentos pueden ser numeros solos o seguidos del %
#	4. Ha de contener almenos el argumento -c seguido del numero integral
#	5. Se ha de tener instalado el paquete bc.
#
# Output:
#
# Cuando el porcentage de memoria swap esta dentro del umbral especificado:
#   Avaliable swaps : [memoria libre]%
#
# Cuando el porcentage de memoria swap esta en estado warning
#	Warning: Avaliable swaps : [memoria libre]%
#
# Cuando el porcentage de memoria swap esta en estado critical
#	Critical: Avaliable swaps : [memoria libre]%
#
# Examples:
#
# ./chek_swaps -c 5 -w 10"
#
NOMBREDELPROGRAMA=$(basename "$0")
NUM_ARGUMENTOS=$#
ARGUMENTO_1="$1"
ARGUMENTO_2="$2"
ARGUMENTO_3="$3"
ARGUMENTO_4="$4"
warning=0
critical=0
lectura=0
i=0
aux=0
total_aux=0
used_aux=0

##################################################
############# Descripcion del contenido ##########
##################################################

Descripcion(){
	echo "check_swaps v1.2"
	echo "Este programa obtiene la memoria swap libre que no es utilizada por el sistema detectando y avisando "
	echo "si se encuentra igual o por debajo del umbral especificado en los argumentos"
	echo ""
}
Opciones_del_programa(){

	echo "Opciones del programa:"
	echo "  -h, --help"
	echo "    Muestra la ayuda para utilitzar este programa"
	echo "  -v, --version"
	echo "    Muestra la version del programa"
	echo ""
}
Argumentos_del_programa(){
	echo "Argumentos del programa:"
	echo "  -c =INTEGER entre 1 to 99"
	echo "    Umbral que si se supera resultara en un estado critico"
	echo "  -w =INTEGER entre 1 to 99"
	echo "    Umbral que si se supera resultara en un estado peligroso"
	echo ""
}

Restricciones_del_programa(){
	echo "Restricciones:"
	echo "  1. El parametro critico ha de ser inferior al parametro peligroso"
	echo "  2. Los dos argumentos han de comprender entre 1 y 99"
	echo "  3. Los argumentos pueden ser numeros solos o seguidos del %"
	echo "  4. Ha de contener almenos el argumento -c seguido del numero integral"
	echo "  5. Se ha de tener instalado el paquete bc."
	echo ""
}

Ejemplos_validos(){
	echo "Ejemplos Validos:"
	echo "  1. ./$NOMBREDELPROGRAMA -c 5 -w 10"
	echo ""
}

Uso_del_programa() {
	Descripcion
	echo "Uso del programa:"
	echo "  ./$NOMBREDELPROGRAMA [-c critical] [-w warning]"
	echo ""
	Opciones_del_programa
	Argumentos_del_programa
	Restricciones_del_programa
	Ejemplos_validos
}
Error_argumentos(){
	echo ""
	echo "Se han introducido mal los argumentos"
	Restricciones_del_programa
	Ejemplos_validos
}

#############################################
###### Comprobacion de los argumentos #######
#############################################

Comprobacion_argumentos(){
	if [ "$ARGUMENTO_3" = "-w" ]; then

		warning=${ARGUMENTO_4//%/}
		critical=${ARGUMENTO_2//%/}

	else
		Error_argumentos
		exit 3
	fi


	if [ $critical -gt 99 -o $critical -lt 1 ]; then
		Error_argumentos
		exit 3

	elif [ $warning -gt 99 -o $warning -lt 1 ]; then

		Error_argumentos
		exit 3

	fi

	if [ $critical -ge $warning ]; then
		Error_argumentos
		exit 3
	fi
}

Filtrar_argumentos(){
	if [ $NUM_ARGUMENTOS -eq 4 ]; then
		if [ "$ARGUMENTO_1" = "-c" ]; then
			Comprobacion_argumentos
			
		else 
			echo "Error en los argumentos"
			Uso_del_programa
			exit 3
		fi
	else
		case $ARGUMENTO_1 in
			--help)
				Uso_del_programa
				exit 1
				;;
			-h)
				Uso_del_programa
				exit 1
				;;
			--version)
				Descripcion
				exit 1
				;;
			-v)
				Descripcion
				exit 1
				;;
			*)
				echo "Error en los argumentos"
				Uso_del_programa
				exit 3
				;;
		esac
	fi	
}
#########################################################
########### Main body of script starts here #############
#########################################################	
	Filtrar_argumentos $1 $2 $3 $4
	total="$(free | awk '{print $2}')"
	used="$(free | awk '{print $3}')"
	for LINE in $total
	do
			if [ $i -eq 2 -a "$LINE" != "buffers/cache:" ]; then
				total_aux=$LINE
				aux=0

			elif [ $i -eq 3 ]; then
					total_aux=$LINE
			fi
			i=`expr $i + 1 `
	done
	i=0
	for LINE in $used
	do
			if [ $aux -eq  1 ]; then	
                                used_aux=$LINE

			elif [ $i -eq 3 ]; then
					used_aux=$LINE
			fi
			i=`expr $i + 1`
	done
	final="$(echo "(1-($used_aux / $total_aux))" | bc -l)"
	final="$(echo "$final*100" | bc -l)"
	final=${final%.*}
	if [ "$final" = "" ]; then
			echo "Critical: Avaliable swaps : 0%"
			exit 2
	elif [ $final -lt $critical ]; then
		echo "Critical: Avaliable swaps : $final %"
		exit 2
	elif [ $final -lt $warning ]; then
		echo "Warning: Avaliable swaps : $final %"
		exit 1
	fi
	echo "Avaliable swaps : $final %"
	exit 0
