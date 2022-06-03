import os
import datetime

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from tempfile import mkdtemp
from werkzeug.security import check_password_hash, generate_password_hash


from helpers import apology, login_required, lookup, usd

# Configure application
app = Flask(__name__)

# Ensure templates are auto-reloaded
app.config["TEMPLATES_AUTO_RELOAD"] = True

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")

# Make sure API key is set
if not os.environ.get("API_KEY"):
    raise RuntimeError("API_KEY not set")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():

    companies_names = db.execute(
        "SELECT company_name, symbol, SUM(shares_number) FROM history WHERE user_id = ? GROUP BY company_name HAVING SUM(shares_number) > 0;", session["user_id"])
    user_cash = db.execute("SELECT cash FROM users WHERE id = ?;", session["user_id"])

    portfolio = []
    total = user_cash[0]["cash"]
    for company in companies_names:
        comp = lookup(company["symbol"])

        current_price = comp["price"]
        symbol = company["symbol"]
        name = company["company_name"]
        num = company["SUM(shares_number)"]
        cash = user_cash[0]["cash"]
        total += current_price * num
        portfolio.append({"name": name, "symbol": symbol, "shares": num, "current": current_price, "cash": cash})

    return render_template("index.html", data=portfolio, total=total)


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    if request.method == "GET":
        return render_template("buy.html")
    else:
        symbol = request.form.get("symbol")
        shares = request.form.get("shares")
        quote = lookup(symbol)
        date = datetime.datetime.now()

        if not symbol:
            return apology("Missing Symbol", 400)
        if not shares:
            return apology("Missing Shares", 400)
        if not shares.isdigit():
            return apology("Invalid Shares", 400)
        if quote == None:
            return apology("Invalid Symbol", 400)

        share_price = quote["price"]
        user = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])
        user_cash = user[0]["cash"]
        total_share_price = share_price * float(shares)

        if user_cash < total_share_price:
            return apology("Not enough money", 400)

        user_cash -= total_share_price
        db.execute("INSERT INTO history (user_id, company_name, symbol, price, shares_number, date) VALUES(?, ?, ?, ?, ?, ?)",
                  session["user_id"], quote["name"], quote["symbol"], quote["price"], shares, date)
        db.execute("UPDATE users SET cash = ? WHERE id = ?;", user_cash, session["user_id"])

        return redirect("/")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    database = db.execute("SELECT symbol, shares_number, price, date FROM history WHERE user_id = ?;", session["user_id"])

    return render_template("history.html", data=database)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":

        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute("SELECT * FROM users WHERE username = ?", request.form.get("username").lower())

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(rows[0]["hash"], request.form.get("password")):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    if request.method == "GET":
        return render_template("quote.html")
    else:
        symbol = request.form.get("symbol")
        quote = lookup(symbol)

        if not symbol:
            return apology("Missing symbol", 400)
        if quote == None:
            return apology("Invalid symbol", 400)

        return render_template("quoted.html", quote=quote)


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    if request.method == "POST":
        username = request.form.get("username").lower()
        password = request.form.get("password")
        confirmed = request.form.get("confirmation")

        """ empty username """
        if not username:
            return apology("must insert username", 400)

        """ if username already exist"""
        db_username = db.execute("SELECT * FROM users WHERE username = :username", username=username)
        if len(db_username) != 0:
            return apology("username already exists", 400)

        """ if password miss or doesn't match """
        if not password:
            return apology("must insert password", 400)
        if confirmed != password:
            return apology("passwords don't match", 400)

        hash = generate_password_hash(password)

        db.execute("INSERT INTO users (username, hash) VALUES(?, ?)", username, hash)

        return render_template("login.html", message="You are registered, you can now login")

    return render_template("register.html")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""
    if request.method == "GET":
        symbols = []
        symbols_ob = db.execute(
            "SELECT DISTINCT symbol FROM history WHERE user_id = ? GROUP BY symbol HAVING SUM(shares_number) > 0;", session["user_id"])
        for symbol in symbols_ob:
            symbols.append(symbol["symbol"])
        return render_template("sell.html", symbols=symbols)

    else:
        symb_check = request.form.get("symbol")
        share_check = request.form.get("shares")
        date = datetime.datetime.now()

        if not symb_check:
            return apology("Missing Symbol", 400)
        if not share_check:
            return apology("Missing Shares", 400)

        shares_check = db.execute("SELECT SUM(shares_number) FROM history WHERE user_id = ? AND symbol = ?;",
                                  session["user_id"], symb_check)
        shares = shares_check[0]["SUM(shares_number)"]

        share_check = int(share_check)

        if share_check < 0:
            return apology("Incorrest shares number", 400)
        if share_check > shares:
            return apology("Too many shares", 400)

        """ aggiungere soldi """
        quote = lookup(symb_check)
        price = quote["price"]
        cash_ob = db.execute("SELECT cash FROM users WHERE id = ?;", session["user_id"])
        cash = cash_ob[0]["cash"]

        total = (price * share_check) + cash
        db.execute("UPDATE users SET cash = ? WHERE id = ?;", total, session["user_id"])

        """ aggiungere shares scelte nel db con numero negativo """
        shares_negative = -abs(share_check)
        db.execute("INSERT INTO history (user_id, company_name, symbol, price, shares_number, date) VALUES(?, ?, ?, ?, ?, ?);",
                   session["user_id"], quote["name"], quote["symbol"], quote["price"], shares_negative, date)

        return redirect("/")
        