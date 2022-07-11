#!/bin/bash

# Este exemplo baixa os dados dos cinco primeiros dias de um determinado mês e ano 
# que são passados como parâmetros para o script
# Um exemplo de execução do script é: ./baixaDadosSaude.sh 1 30 05 2022 Curitiba 

#set -x
# Indicando qual o endereço do site
siteDownload='https://www.saude.pr.gov.br/sites/default/arquivos_restritos/files/documento'
#Variáveis indicando o mês e o ano que irá buscar
diaIni=$1
diaFim=$2
mes=$3
ano=$4
municipio=$5
tipoInfo=$6

# Diretórios que serão utilizados para baixar os dados e processá-los
dataDir="./dados"
tmpDir="./tmp"

# cria diretório
mkdir $dataDir
mkdir $tmpDir

# Nome do arquivo .csv final
csvFinal=$ano$mes$diaIni\-$diaFim\_$municipio\_$tipoInfo.csv

# Executa o for para cada dia (inicio e fim) do período
for dia in $(seq -f "%02g" $diaIni $diaFim); do
  csvFile=informe_epidemiologico_$dia\_$mes\_$ano\_obitos_casos_municipio.csv

  # O comando wget vai baixar o arquivo com os dados do site 
  echo -n "Baixando arquivo $csvFile ..."
  url=$siteDownload/$ano-$mes/$csvFile

  wget $url -P $tmpDir 2> /dev/null
  echo OK

done

# Dados são copiados do diretório temporário para o diretório dados
if [ $tipoInfo -eq 1 ]; then
    cat $tmpDir/*.csv | cut -d';' -f6 --complement > $dataDir/$csvFinal
elif [ $tipoInfo -eq 2 ]; then
    cat $tmpDir/*.csv | cut -d';' -f5 --complement > $dataDir/$csvFinal
else
    cat $tmpDir/*.csv > $dataDir/$csvFinal
fi

# Diretório temporário é apagado
rm -Rf $tmpDir/
