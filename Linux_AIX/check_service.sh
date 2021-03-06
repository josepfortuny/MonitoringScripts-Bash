#!/bin/bash
#
# Detección del estado del servicio para sistemas  la cpu utilizada de los sistemas operativos Lunix/Unix.
# Escrito por Josep Fortuny Casablancas (jfortunycasablancas@gmail.com)
# Ultima Modificación : 07-08-2019
#
# Metodos de uso: 
#
# ./check_service [name of service]
#
# Descripcion:
#
# Este programa consulta el estado del servicio puesto en el argumento y detecta si se esta ejecutando o no
# adaptando el mensaje y la salida dependiento del estado del servicio
#
# Requerimientos para el correcto funcionamiento del programa:
# 
# 1. Dar derechos de administrador al usuario nagios/nrpe añadiendolo al fichero visudo
# 2. Comprovar que el servicio existe en el sistema y puede comprovarse con el commando
#
# Output:
#
# Cuando el servicio esta corriendo correctamente en el sistema:
#   echo "Service [service name] OK"
#
# Cuando el servicio no existe o no esta encendido en el sistema
#	echo "Service [service name] KO"
#
#
# Examples:
#
# ./chek_service httpd
NOMBREDELPROGRAMA=$(basename "$0")
NUM_ARGUMENTOS=$#
ARGUMENTO_1="$1"

##################################################
############# Descripcion del contenido ##########
##################################################
Descripcion(){
	echo "check_service v1.2"
	echo "Este programa consulta el estado del servicio puesto en el argumento y detecta si se esta "
	echo "ejecutando o no adaptando el mensaje y la salida dependiento del estado del servicio."
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
	echo "  Service name =String"
	echo "    Nombre del servicio que se quieren visualizar el estado" 
	echo ""
}

Ejemplos_validos(){
	echo "Ejemplos Validos:"
	echo "  1. ./$NOMBREDELPROGRAMA nagios"
	echo ""
}

Uso_del_programa() {
	Descripcion
	echo "Uso del programa:"
	echo "  ./$NOMBREDELPROGRAMA [-c critical] [-w warning]"
	echo ""
	Opciones_del_programa
	Argumentos_del_programa
	Ejemplos_validos
}
Error_argumentos(){
	echo ""
	echo "Se han introducido mal los argumentos"
	Ejemplos_validos
}

#############################################
###### Comprobacion de los argumentos #######
#############################################
if [ $NUM_ARGUMENTOS -eq 1 ]; then
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
	esac

	if  echo $(sudo service $ARGUMENTO_1 status) | grep -q "running" ; then
			echo "Service $ARGUMENTO_1 OK"
			exit 0
	else
			echo "Service $ARGUMENTO_1 KO"
			exit 2
	fi
else 
	Error_argumentos
	exit 3
fi
