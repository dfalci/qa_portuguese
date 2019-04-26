FROM ubuntu:16.04
MAINTAINER Daniel Falci <danielfalci@gmail.com>

#instala o python3 e pip3
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

ENV APP_BASE="/root/application/" \
    BERT_EMBEDDING_DIR="/root/application/embeddings/" \
    BERT_EMBEDDING_MODEL="multi_cased_L-12_H-768_A-12/" \
    QUESTION_DIR="/root/application/json/" \
    QUESTION_FILE="json.json" \
    PYTHONIOENCODING="UTF-8" \
    LANG=pt_BR.UTF-8


COPY ["./app.py", "/app/app.py"]

#As duas linhas abaixo colocam um embedding default na imagem, bem como o seu respectivo json de configuracao.
COPY ["./embeddings/multi_cased_L-12_H-768_A-12/", "${BERT_EMBEDDING_DIR}/multi_cased_L-12_H-768_A-12/"]
COPY ["./json/json.json", "${QUESTION_DIR}json.json"]


#index.html, etc.
COPY ["./static/", "${APP_BASE}static/"]

#requirements
COPY ["./requirements.txt", "${APP_BASE}requirements.txt"]

#verifica encoding
RUN python3 -c "import sys; print(sys.stdout.encoding)"
RUN echo $LANG

#instala dependencias no python
RUN pip3 install -r ${APP_BASE}requirements.txt

VOLUME $BERT_EMBEDDING_DIR
VOLUME $QUESTION_DIR

WORKDIR "/app/"
EXPOSE 9090

ENTRYPOINT ["python3", "app.py"]


