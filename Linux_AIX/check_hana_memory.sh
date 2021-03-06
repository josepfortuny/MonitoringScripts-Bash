#!/bin/bash
#
# Detección de la memoria libre de la base de datos Hana.
# Escrito por Josep Fortuny Casablancas (jfortunycasablancas@gmail.com)
# Ultima Modificación : 07-08-2019
#
# Metodos de uso: 
#
# ./check_hana_memory [-c critical] [-w warning] [-u user] [-p password]
#
# Descripcion:
# 
# Este programa detecta la memoria libre dentro de la base de datos hana
# e informa si tiene más memoria que la estipulada por los umbrales
# o por el contrario avisa o por el contrario avisa si la memoria
# libre es inferior al umbral especificado en los argumentos.
#
# Requerimientos para el correcto funcionamiento del programa:
# 
# 1. Dar derechos de administrador al usuario nagios/nrpe añadiendolo al fichero visudo
# 2. Crear un usuario tenant en la base de datos para no bloquear el usuario tenant de la base de datos  
# 3. Crear y añadir privilegios para que el usuario root pueda modificarlos y leernos en los siguientes ficheros: 
#  			saphana.check_allocation_metric.sql
#			saphana.check_free_metric.sql
#			check_allocation_metric_output
# 			check_free_metric_output
# 4. Cambiar el directorio por el qual se ejecuta la instancia Hana segun el servidor
#
# Output:
#
# Cuando el porcentage de memoria esta dentro del umbral especificado:
#   Avaliable memory : [memoria libre]%
#
# Cuando el porcentage de memoria esta en estado warning
#	Warning: Avaliable memory : [memoria libre]%
#
# Cuando el porcentage de memoria esta en estado critico
#	Critical: Avaliable memory : [memoria libre]%
#
#
# Examples:
#
# ./chek_hana_memory -c 5 -w 10 -u josep -p contrseña
#
NOMBREDELPROGRAMA=$(basename "$0")
NUM_ARGUMENTOS=$#
ARGUMENTO_1="$1"
ARGUMENTO_2="$2"
ARGUMENTO_3="$3"
ARGUMENTO_4="$4"
ARGUMENTO_5="$5"
ARGUMENTO_6="$6"
ARGUMENTO_7="$7"
ARGUMENTO_8="$8"

##################################################
############# Descripcion del contenido ##########
##################################################

Descripcion(){
	echo "check_sap v1.6"
	echo "  Este programa detecta la memoria libre dentro de la base de datos hana"
	echo "  e informa si tiene más memoria que la estipulada por los umbrales "
	echo "  o por el contrario avisa o por el contrario avisa si la memoria "
	echo "  libre es inferior al umbral especificado en los argumentos."
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
	echo "  -u =String"
	echo "    Nombre del usuario creado en la base de datos hana"
	echo "  -p =String"
	echo "    Contraseña del usuario introducido"
	echo ""
}

Ejemplos_validos(){
	echo "Ejemplos Validos:"
	echo "  1. ./$NOMBREDELPROGRAMA -c 5 -w 10 -u josep -p contrseña"
	echo ""
}
Requerimientos_del_programa(){
	echo "Requerimientos_del_programa:"
	echo "  1. Dar derechos de administrador al usuario nagios/nrpe añadiendolo al fichero visudo"
	echo "  2. Crear un usuario tenant en la base de datos para no bloquear el usuario tenant de la base de datos"
	echo "  3. Crear y añadir privilegios para que el usuario root pueda modificarlos y leernos en los siguientes ficheros:"
	echo " 			saphana.check_allocation_metric.sql"
	echo " 			saphana.check_free_metric.sql"
	echo "			check_allocation_metric_output"
	echo "			check_free_metric_output"
	echo "  4. Cambiar el directorio por el qual se ejecuta la instancia Hana segun el servidor"
	echo ""
}

Uso_del_programa(){
	Descripcion
	echo "Uso del programa:"
	echo "  ./$NOMBREDELPROGRAMA [-c critical] [-w warning] [-u user] [-p password]"
	echo ""
	Opciones_del_programa
	Argumentos_del_programa
	Requerimientos_del_programa
	Ejemplos_validos
}
Error_argumentos(){
	echo ""
	echo "Se han introducido mal los argumentos"
	Requerimientos_del_programa
	Ejemplos_validos
}

#############################################
###### Comprobacion de los argumentos #######
#############################################

Comprobacion_argumentos(){
	if [ "$ARGUMENTO_1" = "-c" -a "$ARGUMENTO_3" = "-w" -a "$ARGUMENTO_5" = "-u" -a "$ARGUMENTO_7" = "-p" ]; then

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
	
	case $NUM_ARGUMENTOS in
		1)
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
					Uso_del_programa
					exit 3
					;;
			esac
		
		;;
		
		8)

				Comprobacion_argumentos
		;;
		*)
				Error_argumentos
				exit 3
		;;
	esac
}

#########################################################
########### Main body of script starts here #############
#########################################################

Filtrar_argumentos

sudo /usr/sap/BPC/hdbclient/hdbsql -i 00 -u $ARGUMENTO_6 -p $ARGUMENTO_8 -m -I /tmp/saphana.check_allocation_metric.sql  > /tmp/check_allocation_metric_output
sudo /usr/sap/BPC/hdbclient/hdbsql -i 00 -u $ARGUMENTO_6 -p $ARGUMENTO_8 -m -I /tmp/saphana.check_free_metric.sql  > /tmp/check_free_metric_output

########################################
###Get total memory assigned hana#######
########################################

file=/tmp/check_allocation_metric_output
uptime=$(sed '2q;d' $file)
IFS=',' # space is set as delimiter
read -ra ADDR <<< "$uptime" # str is read into an array as tokens separated by IFS
total="$(echo ${ADDR[1]} | head -c 5)"
echo "$total"
if [ "$total" = "" ];then
        echo "Failed connecting with Hana Studio"
        exit 2
fi
########################################
###Get free memory assigned hana########
########################################

file=/tmp/check_free_metric_output
uptime=$(sed '2q;d' $file)
IFS=',' # space is set as delimiter
read -ra ADDR <<< "$uptime" # str is read into an array as tokens separated by IFS
free="$(echo ${ADDR[1]} | head -c 5)"

########################################
###Get available memory assigned hana###
########################################

final="$(echo "(1-($free / $total))" | bc -l)"
final="$(echo "$final*100" | bc -l)"
final=${final%.*}

#####################################
#####Send Information to nagios######
#####################################


if [ "$final" = "" ];then
        echo "Critical: Avaliable memory : 0%"
        exit 2
elif [ $final -lt $4 ];then
    echo "Critical: Avaliable memory : $final %"
    exit 2
elif [ $final -lt $2 ];then
    echo "Warning: Avaliable memory : $final %"
    exit 1
fi
echo "Avaliable memory : $final %"
exit 0
