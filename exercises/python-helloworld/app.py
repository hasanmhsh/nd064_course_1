from flask import Flask, jsonify
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

@app.route('/status')
def get_status():
    status = "OK -healthy"
    return jsonify({
        'result': status
    })


@app.route('/metrics')
def get_metrics():
    all_users = 250
    active_users = 32
    return jsonify({
        'data': {
            'UserCount': all_users, 
            'UserCountActive': active_users
        }
    })

    

if __name__ == "__main__":
    app.run(host='0.0.0.0')


