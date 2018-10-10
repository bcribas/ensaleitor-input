# ensaleitor-input
Gerador de entrada para o Ensaleitor

Primeiramente gere o arquivo de configuração descrito no diretório
_gera-config_.

Com o arquivo gerado, utilize o script **gera-disciplinas.sh** para gerar os
arquivos individuais de cada disciplina.

O script **gera-disciplinas.sh** percebe as seguintes informações:

## ALIAS

Quando a disciplina possui o mesmo professor, acontece na mesma hora e na mesma
sala.

É uma configuração muito comum quando se abre uma turma adicional específica
para alunos repetentes ou para dividir igualmente o espaço entre alunos de
diferentes cursos.

## SUBDISCIPLINA

Quando 2 turmas diferentes são dadas pelo mesmo professor e parte delas
acontece no mesmo horário.

Geralmente ocorre com disciplinas que possuem parte teórica em uma sala de
aula e parte prática em um laboratório.

O script, aqui, divide a disciplina em dois arquivos, sendo
  * um arquivo com as aulas em comum [ex, teórica], e;
  * um arquivo com as aulas que acontecem em horários diferente [ex,
    prática].
  * ele mantém as salas nos lugares em que deveriam acontecer.

## AGRUPAMENTO

O agrupamento é a quantidade de aulas consecutivas de cada disciplina. Em
geral as disciplinas de 4horas semanais possuem 2 agrupamentos de 2 aulas.

O script identifica parte dos agrupamentos e configura com o que conseguiu
extrair, algumas coisas saem errado, mas já facilita bastante o processo.

O script também já configura a variável **localthreshold** para 80, não é o
ideal mas já resolve diversas disciplinas. Depois cada especialista deve
conferir os valores.

## SALAS

O script consegue aferir as salas em que a disciplina pode ocorrer, mas não
faz distinção entre laboratório ou aula normal. Assim o **formuleitor** pode
alocar todas as aulas em uma sala que não seja a certa.

Para resolver o problema, deve-se criar um outro arquivo com a parte que
deve acontecer em outra sala.
