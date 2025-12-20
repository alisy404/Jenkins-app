from flask import Flask, jsonify
import socket

app = Flask(__name__)

@app.route("/")
def home():
    return f"""
    <h1>Jenkins CI/CD Deployment Successful 🚀</h1>
    <p>Host: {socket.gethostname()}</p>
    <p>Environment: AWS EC2</p>
    """

@app.route("/health")
def health():
    return jsonify(status="UP"), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
