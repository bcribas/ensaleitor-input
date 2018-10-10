#!/bin/bash

rDISCPLINAS="$*"

declare -A DISCIPLINAS

for arquivo in $rDISCPLINAS; do
while read line; do
  #encontrar código
  if ! grep -q "^<td align=.center. rowspan=." <<< "$line"; then
    continue
  fi

  #provavelmente em codigo
  SUBDISCIPLINAS=$(awk '{print $3}' <<< "$line"|cut -d'"' -f2)
  CODIGO=$(cut -d'>' -f2 <<< "$line" |cut -d'<' -f1)

  if [[ "${DISCIPLINAS[$CODIGO,turmas]}" != "" ]]; then
    echo "--> Repetido $CODIGO" >&2
    CODIGO=repetido-$CODIGO
  fi
  DISCIPLINAS[$CODIGO,turmas]=$SUBDISCIPLINAS

  for((subdisciplina=1;subdisciplina<=$SUBDISCIPLINAS;subdisciplina++));do
    #ler variaveis
    for ler in nome turma vgcalouros vgveteranos vgocup vgrest; do
      read line
      DISCIPLINAS[$CODIGO,$subdisciplina,$ler]="$(cut -d'>' -f2 <<< "$line" |cut -d'<' -f1)"
    done

    #ler horarios
    read line
    read line
    while ! grep -q "^</td>" <<< "$line"; do
      horario=$(tr -d '-' <<< "$line"|awk '{print $1}')
      sala=$(tr -d '-' <<< "$line"|awk '{print $2}')
      DISCIPLINAS[$CODIGO,$subdisciplina,aulas]+="$horario "
      DISCIPLINAS[$CODIGO,$subdisciplina,sala]+="$sala "
      read line
    done

    #pegar professor
    prof="$(grep "\<$CODIGO\>" professores|grep "\<${DISCIPLINAS[$CODIGO,$subdisciplina,turma]}\>"|awk '{print $NF}'|cut -d '@' -f1|head -n1)"
    DISCIPLINAS[$CODIGO,$subdisciplina,professor]="$prof"
  done

done < $arquivo
done

for i in ${!DISCIPLINAS[@]}; do
  echo "$i ${DISCIPLINAS[$i]}"
done
