from flask import Flask, request, render_template

app = Flask(__name__)

SPORT = ["Tennis", "Football", "Rugby", "Golf"]
REGISTRANT = {}

@app.route("/", methods=["POST"])
def index():
    return render_template("index.html", sports=SPORT)

