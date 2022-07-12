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

# Pega o cabeçalho do primeiro csv e escreve no csv final temporário
primeiroCsv=$(ls -d $tmpDir/* | tail -n +1 | head -1)
head -1 $primeiroCsv > $tmpDir/$csvFinal

# Adiciona o conteúdo de todos os csvs no csv final temporário
tail -q -n +2  $tmpDir/*.csv >> $tmpDir/$csvFinal

# Dados são copiados do diretório temporário para o diretório dados
# Se tipoInfo = 1 remove a coluna de óbitos por COVID-19
# Se tipoInfo = 2 remove a coluna de casos de COVID-19
if [ $tipoInfo -eq 1 ]; then
    cat $tmpDir/$csvFinal | cut -d';' -f6 --complement > $dataDir/$csvFinal
elif [ $tipoInfo -eq 2 ]; then
    cat $tmpDir/$csvFinal | cut -d';' -f5 --complement > $dataDir/$csvFinal
else
    cat $tmpDir/$csvFinal > $dataDir/$csvFinal
fi

# Diretório temporário é apagado
rm -Rf $tmpDir/
