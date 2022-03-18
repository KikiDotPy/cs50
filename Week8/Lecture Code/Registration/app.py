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
    return render_template("index.html", sports=SPORT)

@app.route("/register", methods=["POST"])
def register():
    name = request.form.get("name")
    sport = request.form.get("sport")

    if not name or sport not in SPORT:
        return render_template("failure.html")
    else:
        return render_template("success.html")




