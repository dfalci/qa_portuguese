#author - Daniel Falci

from bert_serving.client import BertClient
import numpy as np
import simplejson as json
from bert_serving.server.helper import get_args_parser
from bert_serving.server import BertServer
import os
from flask import Flask, request, send_from_directory
from flask_cors import CORS

#argumentos oriundos do Dockerfile
app_base = os.environ.get('APP_BASE', '/home/daniel/development/pocs/similaridade_bert/')

bert_embedding_dir = os.environ.get('BERT_EMBEDDING_DIR', '/home/daniel/development/pocs/similaridade_bert/embeddings/')
bert_embedding_model = os.environ.get('BERT_EMBEDDING_MODEL', 'multi_cased_L-12_H-768_A-12/')

res_static = app_base+'static'

question_dir = os.environ.get('QUESTION_DIR', '/home/daniel/development/pocs/similaridade_bert/json/')
question_file = os.environ.get('QUESTION_FILE', 'json.json')

f_pretrained = bert_embedding_dir+bert_embedding_model
f_corpus = question_dir+question_file

#modelo a ser carregado
print(f_pretrained)
#corpus a ser carregado
print(f_corpus)


with open(f_corpus, encoding='UTF-8') as f:
    perguntas = json.load(f)
print(json.dumps(perguntas, indent=4, sort_keys=True))

#subindo bert-as-service como modelo embedded
args = get_args_parser().parse_args(['-model_dir', f_pretrained])
server = BertServer(args)
server.start()

#criando cliente do bert-as-service
bc = BertClient()

#preparando corpus de perguntas para vetorizacao
preparado = [{'pergunta':p, 'resposta':item['resposta']} for item in perguntas for p in item['perguntas']]
questoes = [item['pergunta'] for item in preparado]

#Produz os vetores do corpus de perguntas do json
doc_arrays = bc.encode(questoes)

#variavel que indica o numero de perguntas semelhantes a serem exibidos na resposta
topk = 3

#preparando flask para capturar os dados
app = Flask(__name__)
CORS(app)
app.debug = False

@app.route('/documentos', methods = ['GET'])
def usuario():
    """
    metodo para captura
    :return:
    """
    try:
        query = request.args.get('query')
        print("Query do usuario : {}".format(query))
        # se a query do usuario nao terminou com uma interrogacao, coloca uma
        # produzir codigo decente depois
        if not query.endswith(u'?'):
            query = query + u'?'
        #captura o sentence embeddings da query do usuario
        query_arr = bc.encode([query])[0]

        #faz a similaridade do cosseno entre o vetor da query e o vetor das perguntas do corpus
        score = np.sum(query_arr * doc_arrays, axis=1) / np.linalg.norm(doc_arrays, axis=1)

        #captura o indice dos top k elementos com maior similaridade
        topk_idx = np.argsort(score)[::-1][:topk]

        #prepara o retorno
        retorno = {'status':True, 'query':query, 'resposta':None, 'similares':[]}
        for idx in topk_idx:
            retorno['similares'].append({'score':str(score[idx]), 'pergunta':preparado[idx]['pergunta']})

        #adiciona a resposta
        retorno['resposta'] = preparado[topk_idx[0]]['resposta']

        return json.dumps(retorno)

    except BaseException as ex:
        print(ex)
        return json.dumps({'status':False})

@app.route('/<path:path>', methods=['GET'])
def get_resource(path):
    """
    serve arquivos estaticos (index.html)
    :param path:
    :return:
    """
    return send_from_directory(res_static, path)


if __name__ == '__main__':
    #roda a aplicacao na porta 9090
    app.run(host='0.0.0.0', port=9090)
    print("Acesse no http://localhost:9090/index.html")
