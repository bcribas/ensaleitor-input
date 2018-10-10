# Gera configuração das disciplinas

O script **extrair.sh** recebe como entrada um arquivo HTML com as
informações das disciplinas abertas. Temos alguns exemplos das turmas de
2018/2 da UTFPR-PB.

Para gerar o HTML necessário é preciso fazer login no site dos sitemas
corporativos da UTFPR e escolher:
  * Acadêmico
    * No lado esquerdo da tela: Turmas E Horários - Consultas -> Vagas Restantes Após a Matrícula

    * Clicar com o btn direito do mouse, escolher menu "this frame" e depois
      "show page source"
    * Salvar o HTML e passar para o script **extrair.sh**

Exemplo:

```
bash extrair.sh sample/bacharelado-20182
```

Salve a saída em um arquivo e use o script **gera-disciplinas.sh** para
gerar os arquivos das disciplinas.
