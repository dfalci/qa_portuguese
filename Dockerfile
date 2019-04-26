FROM ubuntu:16.04
MAINTAINER Daniel Falci <danielfalci@gmail.com>

#instala o python3 e pip3
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

#roda os requirements
RUN pip3 install unidecode
RUN pip3 install numpy
RUN pip3 install pandas
RUN pip3 install matplotlib
RUN pip3 install scikit-learn
RUN pip3 install tensorflow
RUN pip3 install keras

RUN pip3 install scipy

RUN pip3 install bert-serving-server
RUN pip3 install bert-serving-client

RUN pip3 install flask
RUN pip3 install flask-socketio
RUN pip3 install flask-cors
RUN pip3 install simplejson

ENV APP_BASE="/root/application/"\
    BERT_EMBEDDING_DIR="${APP_BASE}embeddings/"\
    BERT_EMBEDDING_MODEL="multi_cased_L-12_H-768_A-12/"\
    QUESTION_DIR="${APP_BASE}json/"\
    QUESTION_FILE="json.json"\
    PYTHONIOENCODING="UTF-8"\
    LANG=pt_BR.UTF-8


COPY ["./app.py", "/app/app.py"]

#As duas linhas abaixo colocam um embedding default na imagem, bem como o seu respectivo json de configuracao.
COPY ["./embeddings/multi_cased_L-12_H-768_A-12/", "${BERT_EMBEDDING_DIR}/multi_cased_L-12_H-768_A-12/"]
COPY ["./json/json.json", "${QUESTION_DIR}json.json"]

#index.html, etc.
COPY ["./static/", "${APP_BASE}static/"]
#verifica encoding
RUN python3 -c "import sys; print(sys.stdout.encoding)"
RUN echo $LANG

VOLUME $BERT_EMBEDDING_DIR
VOLUME $QUESTION_DIR

WORKDIR "/app/"
EXPOSE 9090

ENTRYPOINT ["python3", "app.py"]


