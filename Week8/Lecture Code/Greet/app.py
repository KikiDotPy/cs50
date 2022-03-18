from flask import Flask, request, render_template

app = Flask(__name__)

@app.route("/")
def index():
    name = request.args.get("name")
    