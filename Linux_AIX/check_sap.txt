#!/bin/ksh
#
# Detección del estado de las instancias SAP que alverga el servidor.
# Escrito por Josep Fortuny Casablancas (jfortunycasablancas@gmail.com)
# Ultima Modificación : 07-08-2019
#
# Metodos de uso: 
#
# ./check_SAP [Modulo] [Instancia]
#
# Descripcion:
# 
# Este programa deteca el estado de la instancia sap introducida en los argumentos
# e informa si esta esta funcionando correctamente o por el contrario avisa si no existe
# o no esta funcionando correctamente
#
# Requerimientos para el correcto funcionamiento del programa:
# 
# 1. Dar derechos de administrador al usuario nagios/nrpe añadiendolo al fichero visudo
# 2. Añadir los usuarios nrpe/nagios al grupo sapsys utilitzando el fichero group ubicado en /etc.  
# 3. Añadir privilegios al fichero /tmp/file_avail.log para que el usuario root lo pueda modificar leer y escribir.
# 
# Output:
#
# Cuando la instancia SAP esta corriendo correctamente en el servidor:
#   Uptime : [fecha desde la qual esta funcionando correctamente]
#   Modulo : [Modulo]
#   Instancia : [Instancia]
#   Status : Green
#
# Cuando la instancia sap no esta corriendo o hay problemas en el estado:
#   Modulo : [Modulo]
#   Instancia : [Instancia]
#   Status : GRAY
#
# Cuando no existe la instancia en el servidor 
#	No existe la instancia [Instancia] del modulo [Modulo]
#
# Examples:
#
# ./chek_SAP scs 01
# ./check_SAP SMDA 98

NOMBREDELPROGRAMA=$(basename "$0")
NUM_ARGUMENTOS=$#
LOG=/tmp/file_avail.log
ARGUMENTO_1="$1"
ARGUMENTO_2="$2"
Estatus_array=0
index_array=0
exit_status=0

##################################################
############# Descripcion del contenido ##########
##################################################

Descripcion(){
	echo "check_sap v1.6"
	echo "  Este programa deteca el estado de la instancia sap introducida en los argumentos"
	echo "  e informa si esta esta funcionando correctamente o por el contrario avisa si no existe"
	echo "  o no esta funcionando correctamente"
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
	echo "  Modulo =String"
	echo "    Modulo sap que esta instalado en el servidor"
	echo "  Instancia =INTEGER entre 0 to 99 "
	echo "    Instancia en la qual se ejecuta el modulo"
	echo ""
}

Ejemplos_validos(){
	echo "Ejemplos Validos:"
	echo "  1. ./$NOMBREDELPROGRAMA scs 01"
	echo "  2. ./$NOMBREDELPROGRAMA SMDA 98"
	echo ""
}
Requerimientos_del_programa(){
	echo "Requerimientos_del_programa:"
	echo "  1. Dar derechos de administrador al usuario nagios/nrpe añadiendolo al fichero visudo"
	echo "  2. Añadir los usuarios nrpe/nagios al grupo sapsys utilitzando el fichero group ubicado en /etc"
	echo "  3. Añadir privilegios al fichero /tmp/file_avail.log para que el usuario root lo pueda modificar leer y escribir"
	echo ""
}

Uso_del_programa(){
	Descripcion
	echo "Uso del programa:"
	echo "  ./$NOMBREDELPROGRAMA [Modulo] [Instancia]"
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
				echo "Error en los argumentos"
				Uso_del_programa
				exit 3
				;;
		esac
	;;

	2)
		MODULE="$ARGUMENTO_1"
		INST="$ARGUMENTO_2"
	;;
	*)
		echo "Error en los argumentos"
		Error_argumentos
		exit 3
	;;
esac
set -A INSTANCIA $INST
##############################
#######get the uptime ########
##############################
get_uptime(){
	aux=0
	file="`sudo cat /tmp/file_avail.log`"
	for LINE in $file
	do
		if [ aux -gt 0 ]; then
			case $aux in
					1)
							year=${LINE}
					;;
					2)
							month=${LINE}
					;;
					3)
							day=${LINE}
					;;
			esac
			aux=`expr $aux + 1 `
		fi
		if [ "$LINE" = "running," ] || [ "$LINE" = "Running," ]; then
			if [ aux -eq 0 ]; then
				aux=1
			fi
		fi
	done
	Estatus_array[index_array]="Uptime: ${day}.${month}.${year}\n"
	index_array=`expr $index_array + 1 `
}

for i in ${INSTANCIA[@]}
do
	############################################
	#Save the status of the instance in a file##
	############################################

	sudo /usr/sap/hostctrl/exe/sapcontrol -nr $i -function GetProcessList > $LOG

	#####################################
	#find in the file instance status ###
	#####################################

	if grep -Rq GRAY $LOG; then
			Estatus_array[index_array]="Modulo: ${MODULE}\nInstancia: ${i}\nStatus: GRAY\n"
			index_array=`expr :$index_array + 1`
			exit_status=2
	elif grep -Rq YELLOW $LOG; then
			Estatus_array[index_array]="Modulo: ${MODULE}\nInstancia: ${i}\nStatus: Yellow\n"
			index_array=`expr $index_array + 1`
			exit_status=2
	elif grep -Rq GREEN $LOG; then
			get_uptime
			Estatus_array[index_array]="Modulo: ${MODULE}\nInstancia: ${i}\nStatus: Green\n"
			index_array=`expr $index_array + 1`
	else
			echo "No existe la instancia $i del modulo $MODULE \n"
			exit_status=2
	fi

done
echo "${Estatus_array[*]}"
exit $exit_status
