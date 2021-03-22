#!/bin/bash
#
# Detección de la cpu utilizada de los sistemas operativos AIX.
# Escrito por Josep Fortuny Casablancas (jfortunycasablancas@gmail.com)
# Ultima Modificación : 07-08-2019
#
# Metodos de uso: 
#
# ./check_cpu [-c critical] [-w warning]
#
# Descripcion:
#
# Este programa obtiene el tanto por ciento usado de la cpu del sistema y  
# la compara con el umbral especificado en los argumentos del programa. Si un 
# umbral es inferior al porcentaje utilizado, adapta el mensaje para mostrar de
# forma clara el estado critico , peligroso o estable de su uso enviando el
# estado de estos. 
#
# Output:
#
# Cuando el porcentage de memoria swap esta dentro del umbral especificado:
#   CPU Used : [CPU libre]%
#
# Cuando el porcentage de memoria swap esta en estado warning
#	Warning: CPU Used : [CPU libre]%
#
# Cuando el porcentage de memoria swap esta en estado Critical
#	Critical: CPU Used : [CPU libre]%
#
# Examples:
#
# ./chek_cpu -c 95 -w 90"

NOMBREDELPROGRAMA=$(basename "$0")
NUM_ARGUMENTOS=$#
ARGUMENTO_1="$1"
ARGUMENTO_2="$2"
ARGUMENTO_3="$3"
ARGUMENTO_4="$4"
warning=0
critical=0
i=0

##################################################
############# Descripcion del contenido ##########
##################################################
Descripcion(){
	echo "check_memory v1.2"
	echo "Este programa obtiene el tanto por ciento usado de la cpu del sistema y "
	echo "la compara con el umbral especificado en los argumentos del programa. Si un"
	echo "umbral es inferior al porcentaje utilizado, adapta el mensaje para mostrar de"
	echo "forma clara el estado critico , peligroso o estable de su uso enviando el"
	echo "estado de estos."
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
	echo "  1. El parametro critico ha de ser superior al parametro peligroso"
	echo "  2. Los dos argumentos han de comprender entre 1 y 99"
	echo "  3. Los argumentos pueden ser numeros solos o seguidos del %"
	echo "  4. Ha de contener almenos el argumento -c seguido del numero integral"
	echo ""
}

Ejemplos_validos(){
	echo "Ejemplos Validos:"
	echo "  1. ./$NOMBREDELPROGRAMA -c 95 -w 90"
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

	if [ $critical -lt $warning ]; then
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
free="$(/usr/bin/iostat | awk '{print $6}')"
for LINE in $free
do
        if [ $i -eq 2 ]; then
                free_aux=$LINE
        fi
        i=`expr $i + 1 `
done
free_aux="$(echo "(100-($free_aux))" | bc -l)"
free_aux=${free_aux%.*}

if [ "$free_aux" = "" ]; then
        echo "CPU Used : 0 %"
        exit 0

elif [ $free_aux -ge $critical ]; then
    echo "Critical: CPU Used : $free_aux %"
    exit 2
elif [ $free_aux -ge $warning ]; then
    echo "Warning: CPU Used : $free_aux %"
    exit 1
fi
echo "CPU Used : $free_aux %"
exit 0
