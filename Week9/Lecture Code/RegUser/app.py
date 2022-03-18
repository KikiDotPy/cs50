from flask import Flask, request, render_template

app = Flask(__name__)

SPORT = ["Tennis", "Football", "Rugby", "Golf"]
REGISTRANT = {}

@app.route("/")
def index():
    return render_template("index.html", sports=SPORT)

@app.route("/register", methods=["POST"])
def register():
    name = request.form.get("name")
    sport = request.form.get("sport")

    if not name:
        return render_template("error.html", message="Missing name")
    if not sport:
        return render_template("error.html", message="Missing sport")
    if sport not in SPORT:
        return render_template("error.html", message="Invalid sport")
    
    REGISTRANT[name] = sport

    return render_template("registrant.html", registrant=REGISTRANT)
