#!/bin/bash

declare -A DISCIPLINAS
declare -A LISTADISCIPLINAS
declare -A PROFESSORES

while read var value; do
  DISCIPLINAS[$var]=$value
  #LISTADISCIPLINAS[${var/,*/}]=t

  if [[ "${var##?*,[0-9],}" == "professor" ]]; then
    PROFESSORES[$value]+=" ${var%,professor}"
  fi
done < $1

function comparaturmas()
{
  local A=$1
  local B=$2
  ## repostas para aliases
  ### turmas com mesmos horarios e mesmos professores
  if [[ "${DISCIPLINAS[$A,aulas]}" == "${DISCIPLINAS[$B,aulas]}" && -n "${DISCIPLINAS[$A,aulas]}" ]]; then
    return 1
  elif [[ "${A%,[0-9]}" == "${B%,[0-9]}" && -z "${DISCIPLINAS[$A,aulas]}" && -n "${DISCIPLINAS[$B,aulas]}" ]]; then
    return 2
  elif [[ "${A%,[0-9]}" == "${B%,[0-9]}" && -z "${DISCIPLINAS[$B,aulas]}" && -n "${DISCIPLINAS[$A,aulas]}" ]]; then
    return 1
  fi

  ## respostas para subdivisao
  ### duas turmas com mesmo professor, compartilhando parte dos horários
  same=0
  for aulaA in ${DISCIPLINAS[$A,aulas]}; do
    for aulaB in ${DISCIPLINAS[$B,aulas]}; do
      if [[ "$aulaA" == "$aulaB" ]]; then
        ((same++))
      fi
    done
  done
  declare -a aulaAv
  declare -a aulaBv
  aulaAv=(${DISCIPLINAS[$A,aulas]})
  aulaBv=(${DISCIPLINAS[$B,aulas]})
  if (( same < ${#aulaAv[@]} + ${#aulaBv[@]} && same > 0 )); then
    return 3
  fi
  return 0
}

function subturma()
{
  A=$1
  B=$2
  declare -a aulaAv
  declare -a aulaAs
  declare -a aulaBv
  declare -a aulaBs
  aulaAv=(${DISCIPLINAS[$A,aulas]})
  aulaBv=(${DISCIPLINAS[$B,aulas]})
  aulaAs=(${DISCIPLINAS[$A,sala]})
  aulaBs=(${DISCIPLINAS[$B,sala]})

  #separar as turmas por sala, assim podemos ter algo como um código de
  #turma teórica e outro para aula prática
  declare -A novoaulaA
  declare -A novoaulaB
  declare -a iguais
  for i in ${!aulaAv[@]}; do
    for j in ${!aulaBv[@]}; do
      if [[ "${aulaAv[$i]}" == "${aulaBv[$j]}" ]]; then
        iguais+=("$i $j")
      fi
    done
  done

  for it in "${iguais[@]}"; do
    read a b <<< "$it"
    novoaulaA[${aulaAv[$a]}]=${aulaAs[$a]}
    unset aulaAv[$a]
    unset aulaAs[$a]
    unset aulaBv[$b]
    unset aulaBs[$b]
  done
  DISCIPLINAS[$A,aulas]="${!novoaulaA[@]}"
  DISCIPLINAS[$A,sala]="${novoaulaA[@]}"
  DISCIPLINAS[$B,aulas]="${aulaAv[@]} ${aulaBv[@]}"
  DISCIPLINAS[$B,sala]="${aulaAs[@]} ${aulaBs[@]}"
  DISCIPLINAS[$A,alias]+=" ${DISCIPLINAS[$B,turma]}-s"
  DISCIPLINAS[$B,alias]+=" ${DISCIPLINAS[$A,turma]}-s"
}

for professor in ${!PROFESSORES[@]}; do
  for d1 in ${PROFESSORES[$professor]}; do
    if [[ "${DISCIPLINAS[$d1,turma]}" == "" ]]; then continue;fi
    for d2 in ${PROFESSORES[$professor]#?*$d1};do
      if [[ "${DISCIPLINAS[$d2,turma]}" == "" ]]; then continue;fi
      comparaturmas $d1 $d2
      RET=$?
      if (( RET == 1 )); then
        DISCIPLINAS[$d1,alias]+=" ${d2%,[0-9]}-${DISCIPLINAS[$d2,turma]}"
        LISTADISCIPLINAS[$d1]=t
        unset DISCIPLINAS[$d2,turma]
      elif (( RET == 2 )); then
        DISCIPLINAS[$d2,alias]+=" ${d1%,[0-9]}-${DISCIPLINAS[$d1,turma]}"
        unset DISCIPLINAS[$d1,turma]
        LISTADISCIPLINAS[$d2]=t
      elif (( RET == 3 )); then
        echo "SUB: $d1 $d2"
        subturma $d1 $d2
      fi
    done
  done

  for d1 in ${PROFESSORES[$professor]}; do
    if [[ "${DISCIPLINAS[$d1,turma]}" == "" ]]; then continue;fi
    LISTADISCIPLINAS[$d1]=t
  done
done

if false; then
for disciplina in ${!LISTADISCIPLINAS[@]}; do
  turmas=${DISCIPLINAS[$disciplina,turmas]}
  for((i=1;i<=turmas;i++));do
    aulas=(${DISCIPLINAS[$disciplina,$i,aulas]})
    for((j=2;j<=turmas;j++));do
      if [[ "${DISCIPLINAS[$disciplina,$j,turma]}" == "" ]]; then continue;fi
      aulasj=(${DISCIPLINAS[$disciplina,$i,aulas]})
      if [[ "${#aulas[@]}" == 0 || "${#aulasj[@]}" == 0 ]] || ( [[ "${aulas[@]}" == "${aulasj[@]}" ]] &&
          [[ "${DISCIPLINAS[$diciplina,$i,professor]}" == "${DISCIPLINAS[$disciplina,$j,professor]}" ]]) ; then
        DISCIPLINAS[$disciplina,$i,alias]+="$disciplina-${DISCIPLINAS[$disciplina,$j,turma]} "
        aulas=(${aulasj[@]})
        DISCIPLINAS[$disciplina,$i,aulas]="${aulas[@]}"
        (( DISCIPLINAS[$disciplina,turmas]--))
      fi
    done
  done
done
fi

mkdir -p disciplinas
for disciplina in ${!LISTADISCIPLINAS[@]}; do
  c="${disciplina%,*}"
  turma=${DISCIPLINAS[$disciplina,turma]}
  declare -a aulas
  declare -l tmp
  tmp="${DISCIPLINAS[$disciplina,aulas]}"
  DISCIPLINAS[$disciplina,aulas]="$tmp"
  aulas=()
  aulas=(${DISCIPLINAS[$disciplina,aulas]})
  if (( ${#aulas[@]} == 0 )); then continue; fi

  unset salas
  declare -A salas
  for s in ${DISCIPLINAS[$disciplina,sala]}; do
    salas[$s]=t
  done

  GRUPOS=""
  for k in 2m 2t 2n 3m 3t 3n 4m 4t 4n 5m 5n 5t 6m 6t 6n 7m; do
    if grep -q "$k" <<< "${aulas[@]}"; then
      CONT=$(echo "${aulas[@]}"|tr ' ' '\n'|grep -c "$k")
      if (( CONT > 0 )); then
        GRUPOS+="$CONT "
      fi
    fi
  done

  cat > disciplinas/$c-$turma << EOF
professor ${DISCIPLINAS[$disciplina,professor]}
aulas ${#aulas[@]}
agrupamento $GRUPOS
salas ${!salas[@]}
turnos ${DISCIPLINAS[$disciplina,aulas]}
fullname ${DISCIPLINAS[$disciplina,nome]}
periodo ${DISCIPLINAS[$disciplina,turma]}
localthreshold 80
alias ${DISCIPLINAS[$disciplina,alias]}
EOF
done
