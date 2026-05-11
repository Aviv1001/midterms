import os
import socket
import sys

from flask import Flask, jsonify, redirect, render_template, request


def load_api_key():
    api_key = os.environ.get("API_KEY")
    if not api_key:
        print("Error: API_KEY environment variable is required.", file=sys.stderr)
        sys.exit(1)
    return api_key


PORT = int(os.environ.get("PORT", "5000"))
VERSION = os.environ.get("VERSION", "1.0.0")
API_KEY = load_api_key()

app = Flask(__name__)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/api/status")
def api_status_redirect():
    return redirect("/api/v1/status")


@app.route("/api/v1/status")
def api_v1_status():
    return jsonify(
        status="ok",
        hostname=socket.gethostname(),
        version=VERSION,
    )


@app.route("/api/v1/secret")
def api_v1_secret():
    if request.headers.get("X-API-Key") != API_KEY:
        return jsonify(error="unauthorized"), 401
    return jsonify(message="mazal tov!! You found the secret message!")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)
