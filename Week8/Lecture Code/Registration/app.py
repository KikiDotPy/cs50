from flask import Flask, request, render_template

app = Flask(__name__)
SPORT = [
    "Football",
    "Tennis",
    "Regby",
    "Golf"
]

@app.route("/")
def index():
    return render_template("index.html")



