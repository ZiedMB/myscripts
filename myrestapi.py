import json
import bottle
from bottle import route, run, request, abort
from pymongo import Connection
from bson.json_util import dumps
 
connection = Connection('localhost', 27017)
db = connection.ccev2
 
@route('/documents', method='PUT')
def put_document():
    data = request.body.readline()
    if not data:
        abort(400, 'No data received')
    entity = json.loads(data)
    if not entity.has_key('_id'):
        abort(400, 'No _id specified')
    try:
        db['documents'].save(entity)
    except ValidationError as ve:
        abort(400, str(ve))
     
@route('/config/:id', method='GET')
def get_document(id):
    entity = db['config'].find({'id':id})
    print(entity)
    if not entity:
        abort(404, 'No document with id %s' % id)
    return dumps(entity)
 
run(host='10.0.0.47', port=8080)
