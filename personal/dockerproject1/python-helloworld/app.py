from flask import Flask, jsonify, json
app = Flask(__name__)
import logging

# logging.basicConfig(filename='record.log', level=logging.DEBUG, format=f'%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s')
logging.basicConfig(filename='app.log', level=logging.DEBUG, format=f'%(asctime)s, %(message)s')

@app.route("/")
def hello():
    app.logger.info('/  endpoint was reached')
    return "Hello World!"

@app.route('/status')
def get_status():
    app.logger.info('/status  endpoint was reached')
    status = "OK -healthy"
    return jsonify({
        'result': status
    })


@app.route('/metrics')
def get_metrics():
    app.logger.info('/metrics  endpoint was reached')
    all_users = 250
    active_users = 32
    return jsonify({
        'data': {
            'UserCount': all_users, 
            'UserCountActive': active_users
        }
    })

@app.route('/status_uda_solution')
def status():
    response = app.response_class(
            response=json.dumps({"result":"OK - healthy"}),
            status=200,
            mimetype='application/json'
    )

    return response

@app.route('/metrics_uda_solution')
def metrics():
    response = app.response_class(
            response=json.dumps({"status":"success","code":0,"data":{"UserCount":140,"UserCountActive":23}}),
            status=200,
            mimetype='application/json'
    )

    return response


if __name__ == "__main__":
    logging.basicConfig(filename='app.log',level=logging.DEBUG)
    app.run(host='0.0.0.0')#, debug=True)


