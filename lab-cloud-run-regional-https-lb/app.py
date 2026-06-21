from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello():
    return {"message": "Hello depuis Cloud Run via Load Balancer !", "status": "ok"}

@app.route("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
