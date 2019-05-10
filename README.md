# Usando BERT para um sistema de Question & Answering em português
#### Daniel Falci

Antes de começarmos, precisamos de um corpus de perguntas e respostas. Como teste, capturamos as perguntas disponíveis no FAQ publicado no endereço http://www.acessoainformacao.gov.br/perguntas-frequentes/aspectos-gerais-da-lei#1 . Trata-se de um corpus com treze perguntas diferentes sobre a lei de acesso à informação. Acesse o site para se familiarizar com as perguntas respondidas neste FAQ.


Primeiro um teste 100% dentro da caixa... Execute o comando abaixo:


```
docker run --rm -it --name qa_portugues -p 9090:9090 danielfalci/qa_portugues:latest
```

###### Obs: Você precisa de uma máquina com pelo menos 8GB de RAM livre.

Aguarde até que o sistema informe (este procedimento pode demorar bastante tempo, dependendo da máquina host):

```terminal
 * Running on http://0.0.0.0:9090/ (Press CTRL+C to quit)
```

Agora, acesse o endereço http://localhost:9090/index.html no seu browser e, livremente, faça perguntas previstas no faq sobre  a "Lei de acesso à informação".

Legal, não?

### Personalizando as perguntas e respostas

Agora vamos customizar o sistema com perguntas e respostas inteiramente novas. Para isso, precisamos criar um novo arquivo (formato json) que contenha o novo conhecimento a ser analisado. O arquivo json utilizado no teste anterior (empacotado nesta imagem docker) segue o seguinte formato:

```
[
  {
    "perguntas": [
      "O que é a lei de acesso à informação?",
      "Como funciona a lei de acesso à informação?",
      "Como funciona?",
      "Quem criou a lei de acesso à informação?"
    ],
    "resposta": "A Lei nº 12.527/2011, conhecida como Lei de Acesso à Informação - LAI, regulamenta o direito, previsto na Constituição, de qualquer pessoa solicitar e receber dos órgãos e entidades públicos, de todos os entes e Poderes, informações públicas por eles produzidas ou custodiadas."
  },
  {
    "perguntas": [
      "Quando a lei de acesso à informação entrou em vigor?",
      "Em que momento a lei de acesso à informação começou a funcionar?",
      "A lei de acesso a informação vale à partir de que momento?",
      "Quando a lei de acesso à informação foi publicada?",
      "Quando a lei de acesso passou a valer em território nacional?"
    ],
    "resposta": "A LAI foi publicada em 18 de novembro de 2011, mas só entrou em vigor 180 (cento e oitenta) dias após essa data, ou seja, em 16 de maio de 2012."
  },
  ...
]
```
#### O json é um array de objetos onde cada objeto indica uma coleção de perguntas prototípicas que levam a uma resposta.

Crie um novo arquivo com extensão json em um diretório qualquer da sua máquina. Nele, escreva a sua coleção de perguntas e respostas, mantendo o formato indicado acima. 

Vamos executar o sistema novamente: Desta vez, faremos um bind informando o diretório onde o corpus está gravado (-v), bem como o nome deste novo arquivo (-e). Abaixo o exemplo: 
```
docker run --rm -it --name qa_portugues \ 
    -p 9090:9090 \ 
    -v /caminho da minha maquina/:/root/application/json/ \ 
    -e QUESTION_FILE="novoarquivo.json" \ 
    danielfalci/qa_portugues:latest
```

Agora é só acessar http://localhost:9090/index.html e testar a performance no seu corpus exclusivo. 

Para algo pré-treinado, os resultados são excepcionais não acha?
