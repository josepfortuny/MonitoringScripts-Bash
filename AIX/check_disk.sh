#!/bin/bash
#
# Detección de la ocupacion de los file systems del sistema operativo AIX
# Escrito por Josep Fortuny Casablancas (jfortunycasablancas@gmail.com)
# Ultima Modificación : 07-08-2019
#
# Metodos de uso: 
#
# ./check_disk [-c critical] [-w warning]
# ./check_disk [-c critical]
#
# Descripcion:
# Este programa obtiene el tanto por ciento libre del disco y lo compara 
# con el umbral especificado en los argumentos del programa. Si un umbral
# es superior al porcentaje libre de un file system adapta el mensaje para
# mostrar de forma clara el file system en estado critico o peligroso y envia
# el estado de estos. 
#
# Output:
#
# Cuando todos los file systems por encima del umbral especificado:
#   Todos los file sistems cumplen los parametros
#
# Cuando uno o mas file systems esta en estado warning
#	############# WARNING ##############
#	FS : <nombre file sistem> -- FREE: <INTEGER libre>%
#
# Cuando uno o mas file systems esta en estado warning
#	############# CRITICAL ##############
#	FS : <nombre file sistem> -- FREE: <INTEGER libre>%
#
# Examples:
#
# ./chek_disk -c 5 -w 10"
# ./check_disk -c 5
#
NOMBREDELPROGRAMA=$(basename "$0")
NUM_ARGUMENTOS=$#
ARGUMENTO_1="$1"
ARGUMENTO_2="$2"
ARGUMENTO_3="$3"
ARGUMENTO_4="$4"
j=0
lectura=0 
i=0
x=0
l=0
array_index_critico=0
array_index_warning=0
array_valores_criticos=0
array_valores_warning=0
myarray=0
warning=0
critical=0

Descripcion(){
	echo "check_disk v2.2"
	echo "Este programa obtiene el espacio libre de los file sistems, detectando y avisando "
	echo "si hay algun file sistem igual o por debajo del umbral especificado en los argumentos"
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
	echo ""
}

Ejemplos_validos(){
	echo "Ejemplos Validos:"
	echo "  1. ./$NOMBREDELPROGRAMA -c 5 -w 10"
	echo "  2: ./$NOMBREDELPROGRAMA -c 5"
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
Comprobacion_dos_argumentos(){
	
	critical=${ARGUMENTO_2//%/}
	if [ $critical -gt 99 -o $critical -lt 1 ]; then
		Error_argumentos
		exit 3
	fi

}
#############################################
###### Comprobacion de los argumentos #######
#############################################

Comprobacion_cuatro_argumentos(){
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

	if [ $critical -lt $warning ]; then
		:
	else
		Error_argumentos
		exit 3
	fi
}



Filtrar_argumentos(){
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
		-c)
			shift
			;;
		*)
			Uso_del_programa
			exit 3
			;;
	esac
	case $NUM_ARGUMENTOS in
        2)
                Comprobacion_dos_argumentos $1 $2
        ;;
        4)

                Comprobacion_cuatro_argumentos $1 $2 $3 $4
        ;;
        *)
				Ejemplos_validos
                exit 3
        ;;
    esac
}

#########################################################
########### Main body of script starts here #############
#########################################################
	Filtrar_argumentos $1 $2 $3 $4
	ssh_comand="`df -g | awk '{print $4}'`"
	ejecutable=${ssh_comand//%/}
	for LINE in $ejecutable
	do
		lectura=$LINE
		if [ "$lectura" = "-" -o  "$lectura" = "Free" ];then
				:
		else
			lectura=`expr 100 - $lectura`
			if [ $lectura -le $critical ]; then
				array_index_critico[i]=$j
				array_valores_criticos[i]=$lectura
				i=`expr $i + 1 `

			elif [ $NUM_ARGUMENTOS -eq 4 ]; then

				if [ $lectura -le $warning -a  $lectura -gt $critical ]; then
					array_index_warning[x]=$j
					array_valores_warning[x]=$lectura
					x=`expr $x + 1 `
				fi
			fi
		fi
		j=`expr $j + 1 `
	done
	j=0
	if [ $x -gt 0 -o $i -gt 0 ]; then
		if [ $i -gt 0 ]; then

			myarray[l]="############# CRITICAL ##############"'\n'
			l=`expr $l + 1 `
			j=0
			i=0
			ejecutable="`df -g | awk '{print $7}'`"
			for LINE in $ejecutable
			do
				if [ "${array_index_critico[$j]}" == "$i" ]; then

					myarray[l]="FS: $LINE -- FREE:  ${array_valores_criticos[$j]}%"'\n'
					j=`expr $j + 1 `
					l=`expr $l + 1 `

				fi
				i=`expr $i + 1 `
			done
		fi
		if [ $NUM_ARGUMENTOS -eq 4 -a $x -gt 0 ]; then
			myarray[l]="############# WARNING ##############"'\n'
			l=`expr $l + 1 `
			i=0
			k=0
			ejecutable="`df -g | awk '{print $7}'`"
			for LINE in $ejecutable
			do
				if [ "${array_index_warning[$k]}" == "$i" ]; then
					myarray[l]="FS: $LINE -- FREE:  ${array_valores_warning[$k]}%"'\n'
					k=`expr $k + 1 `
					l=`expr $l + 1 `
				fi

				i=`expr $i + 1 `
			done
		fi
		echo ${myarray[*]}
		if [ $j -gt 0 ]; then
				exit 2
		else
				exit 1
		fi
	fi
	echo "Todos los file sistems cumplen los parametros"
	exit 0
