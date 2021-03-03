#!/bin/bash

# ===============================================================================
#
#  PRÁCTICA 4. PFAM Y HMMER3
#
# ===============================================================================
#
# Esto es un ejemplo de script para resolver el ejercicio de la práctica, con
# algunos comentarios para entender cómo funciona.
#
# ----------------------------
#  SHEBANG
# ----------------------------
#
# Todas las líneas que empiezan por "#" son comentarios y seran ignorados por BASH.
# Pero si la primera línea del script empieza por "#!", esto tiene un significado
# especial: informa a BASH del lenguaje en que está escrito el código, y por tanto
# indica qué intérprete debe ejecutarlo. Por ejemplo, "#!/bin/python" para un script
# de python o "#!/bin/bash" para un script the BASH como este. Para saber en qué
# dirección de tu ordenador se encuentra el programa bash, puedes ejecutar en la 
# terminal el comando "which bash". Si el resultado fuera "/usr/bin/bash", entonces,
# la primera línea de los scripts de BASH debería ser "#!/usr/bin/bash".
#
# -----------------------------
#  DEPENDENCIAS
# -----------------------------
#
# Para que este script funcione tiene que estar instalado el programa hmmer3. Esto
# es una "dependencia". Si trabajamos en un ordenador virtual o prestado, no tendremos
# privilegios de administración. En este caso, podemos usar el gestor de ambientes
# "conda", que afortunadamente aparece instalado por defecto en las máquinas de MyBinder.
#
# Sin embargo, no es buena idea incluir en un script los comandos de instalacion de
# sus dependencias (a no ser que sepamos muy bien lo que estamos haciendo). Los motivos
# son dos: el script lo podemos ejecutar muchas veces, pero la instalación de las
# dependencias solo hace falta hacerla la primera vez; además, "conda" interacciona
# con la persona usuaria, pidiendo que confirme la instalación (aunque haya formas de
# prevenirlo), lo que interrumpiría el script innecesariamente.
#
# Así pues, a continuación indico cómo instalar hmmer3, pero en una línea que empieza
# por "#" y que por tanto no será ejecutada. Usa esta sintaxis manualmente para instalar
# hmmer3 si no está ya instalado:
#
#   conda install -c bioconda hmmer
#
# Después de haber ejectuado la línea anterior, tendremos disponibles los programas
# "hmmbuild", "hmmsearch", "hmmscan", etc.
#
# -----------------------------------------------
#  CONSTRUCCIÓN DE UN HMM PARA CADA DOMINIO
# -----------------------------------------------
#
# Cada vez que se ejecute este script se crearan o sobre-escribirán los archivos
# terminados en .hmm. La sintaxis del programa hmmbuild és:
#
#   hmmbuild [-options] <hmmfile_out> <msafile>
#
# Es decir, al nombre del comando le siguen dos o más argumentos: las possibles opciones,
# el nombre del archivo de salida y el nombre del archivo con el alineamiento múltiple.
# Los alineamientos múltiples se encuentran ya en la carpeta de trabajo y sus nombres 
# terminan con la extension ".sto" porque están en formato Stocholm.
#
# Lo que hacemos con los comandos siguientes es crear un modelo de Markov oculto para
# cada uno de los cuatro dominios del clan ANL a partir de sus alineamientos "semilla",
# tomados de la base de datos de Pfam.

hmmbuild AMP-binding.hmm AMP-binding_seed.sto
hmmbuild ACAS_N.hmm      ACAS_N_seed.sto
hmmbuild GH3.hmm         GH3_seed.sto
hmmbuild LuxE.hmm        LuxE_seed.sto

# Observa que los espacios adicionales han sido añadidos para que los cuatro comandos
# anteriores estén alineados, por motivos puramente estéticos.
#
# ----------------------------------------------
#  CONCATENACIÓN DE LOS HMMs
# ----------------------------------------------
#
# El siguiente paso es juntar los cuatro modelos ocultos de Markov en un único archivo,
# que será nuestra pequeña base de datos de dominios. Esto se consigue en bash con el
# comando "cat" que concatena todos los inputs, uno detrás de otro, y los devuelve, bien
# a la pantalla de la terminal o bien a un archivo de salida si lo especificamos después
# del símbolo ">". Este símbolo redirecciona la salida estándard:

cat AMP-binding.hmm ACAS_N.hmm GH3.hmm LuxE.hmm > ANL_clan

# En este caso he nombrado el nuevo archivo "ANL_clan.hmm". Podría haber conseguido lo
# mismo mediante un "atajo", pidiendo a "cat" que uniera "todos los archivos de esta
# carpeta cuyos nombres terminan en ".hmm":
#
#    cat *.hmm > ANL_clan
#
# ---------------------------------------------------------
#  COMPRESIÓN E INDEXACIÓN DE LA BASE DE DATOS DE DOMINIOS
# ---------------------------------------------------------
#
# Aunque nuestra base de datos es pequeña, la búsqueda eficiente de dominios en una o
# más secuencias requiere el indexado previo de la base de datos de dominios, que en
# nuestro caso es el archivo "ANL_clan". Esto lo conseguimos con el programa "hmmpress",
# de hmmer3:

hmmpress ANL_clan

# Este es el comando que genera los archivos ANL_clan.h3f, ANL_clan.h3i, ANL_clan.h3m
# y ANL_clan.h3p, que són el índice binario de ANL_clan. Ahora ya estamos preparados para
# buscar las proteínas de Salinibacter ruber entre los dominios del clan ANL:
#
# ---------------------------------------------
#  ESCANEAR UNA BASE DE DATOS DE DOMINIOS
# ---------------------------------------------
#
# Los programas "hmmscan" y "hmmsearch" son muy parecidos. Normalmente usamos "hmmscan"
# cuando buscamos cualquier dominio de los presentes en una base de datos de dominios
# en una o más secuencias proteicas de partida. Por el contrario, si lo que buscamos es
# un dominio particular (o unos pocos) en una base de datos de muchas secuencias proteicas,
# entonces usaríamos "hmmsearch". En nuestro caso, podemos usar los dos, porque en nuestra
# base de datos hay solo 4 dominios y en el archivo fasta hay 2780 proteínas predichas
# en el genoma de Salinibacter ruber. Empecemos por "hmmscan". Podemos aprender su uso
# con el comando "man hmmscan", donde aprendemos que la sintaxis es esta:
#
#    hmmscan [-options] <hmmdb> <seqfile>
#
# Donde "<hmmdb>" es el nombre de la base de datos comprimida (ANL_clan, en nuestro caso)
# y "<seqfile>" es el nombre del archivo que contiene la(s) secuencia(s) (Salinibacter_ruber.fasta).
# Entre las opciones que nos muestra la ayuda de hmmscan encontramos "--tblout <f>" y "--domtblout <f>",
# lo que significa que puede producir un archivo resumen en forma de tabla con una línea por
# cada secuencia con algún dominio encontrado (--tblout) o bien una tabla con los diferentes dominios
# encontrados en cada secuencia separados en líneas diferentes (--domtblout). Añadiremos estas
# dos opciones al comando para comparar las tablas generadas.

hmmscan --tblout perSeq.out --domtblout perDom.out ANL_clan Salinibacter_ruber.fasta

# Esto creará las tablas perSeq.out y perDom.out, además de una copiosa salida en pantalla
# que podemos ignorar.
#
# ------------------------------------------------
#  ESCANEAR UNA BASE DE DATOS DE SECUENCIAS
# ------------------------------------------------
#
# Si partimos de unos pocos dominios que queremos buscar en una base de datos de secuencias,
# entonces es más apropiado usar "hmmsearch". Esto se parece much a una búsqueda con el
# algoritmo BLAST (véase el tema 6).

hmmsarch --tblout perSeq_search.out --domtblout perDom_search.out ANL_clan Salinibacter_ruber.fasta

# Si comparas las tablas generadas por hmmscan y hmmsearch verás que tienen casi la misma
# información. La diferencia es en lo que cada programa considera la "query" (o término de
# búsqueda) y la diana ("target").