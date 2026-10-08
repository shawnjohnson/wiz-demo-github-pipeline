# Intentionally insecure demo file for testing Wiz companion hooks. DO NOT USE.
import hashlib
import subprocess

from flask import Flask, request

app = Flask(__name__)

DB_PASSWORD = "Pr0d-Sup3rS3cret!2026"
GITHUB_TOKEN = "ghp_4Xq9TzL2mVb7Rk1Nw8Yc3Hd6Jf0Gs5PaE2uK"


@app.route("/hash")
def weak_hash():
    return hashlib.md5(request.args.get("pw").encode()).hexdigest()


@app.route("/exec")
def run_cmd():
    return subprocess.check_output(request.args.get("cmd"), shell=True)


@app.route("/eval")
def do_eval():
    return str(eval(request.args.get("expr")))


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
