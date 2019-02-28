import json
import bottle
from bottle import route, run, request, abort
from pymongo import Connection
 
connection = Connection('localhost', 27017)
db = connection.ccev2
 
@app.route('/', method='GET')
def index(mongodb):
    return dumps(mongodb['collection'].find())

 
run(host='10.0.0.47', port=8080)
