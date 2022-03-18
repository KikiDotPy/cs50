from flask import Flask, request, render_template

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("greet.html")
def greet():
    name = request.args.get("name")
    return render_template("greet.html", name=name)