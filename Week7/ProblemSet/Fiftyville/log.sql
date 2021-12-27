-- Keep a log of any SQL queries you execute as you solve the mystery.
-- The crime took place on July 28, 2020 and that it took place on Chamberlin Street.

-- I've searched through the crime reports to have more info about the crime based on the little info I have to start with
SELECT * FROM crime_scene_reports WHERE year = 2020 AND month = 7 AND day = 28;
-- RESULT:
-- 295 | 2020 | 7 | 28 | Chamberlin Street | Theft of the CS50 duck took place at 10:15am 
-- at the Chamberlin Street courthouse. Interviews were conducted today with three witnesses 
-- who were present at the time — each of their interview transcripts mentions the courthouse.

-- Since in the report is mentioned there are 3 witnesses I've then searched in the same day of the crime in the interviews database with COURTHOUSE keyword
SELECT * FROM interviews WHERE transcript LIKE '%courthouse%' AND year = 2020 AND month = 7 AND day = 28;
-- 1° WITNESS:
-- Ruth | 2020 | 7 | 28 | 
-- Sometime within ten minutes of the theft, I saw the thief get into a car in the courthouse parking lot and drive away. 
-- If you have security footage from the courthouse parking lot, you might want to look for cars that left the parking lot 
-- in that time frame.
-- 2° WITNESS:
-- 162 | Eugene | 2020 | 7 | 28 | 
-- I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at the courthouse, 
-- I was walking by the ATM on Fifer Street and saw the thief there withdrawing some money.
-- 3° WITNESS:
-- 163 | Raymond | 2020 | 7 | 28 | 
-- As the thief was leaving the courthouse, they called someone who talked to them for less than a minute. 
-- In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. 
-- The thief then asked the person on the other end of the phone to purchase the flight ticket.

-- Searched for the car mentioned from the 1° witnesses in the window between 10:15 and 10:25 to try to retrieve LICENSE PLATE
SELECT * FROM courthouse_security_logs 
WHERE year = 2020 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25;
-- RESULT:
-- 260 | 2020 | 7 | 28 | 10 | 16 | exit | 5P2BI95
-- 261 | 2020 | 7 | 28 | 10 | 18 | exit | 94KL13X x
-- 262 | 2020 | 7 | 28 | 10 | 18 | exit | 6P58WS2
-- 263 | 2020 | 7 | 28 | 10 | 19 | exit | 4328GD8 x
-- 264 | 2020 | 7 | 28 | 10 | 20 | exit | G412CB7
-- 265 | 2020 | 7 | 28 | 10 | 21 | exit | L93JTIZ x
-- 266 | 2020 | 7 | 28 | 10 | 23 | exit | 322W7JE x
-- 267 | 2020 | 7 | 28 | 10 | 23 | exit | 0NTHK55

-- Since the result of the 1° witness for now are useless, I proceed searching on the clue of the 2° witness, searching on ATM log in the adress indicated
SELECT * FROM atm_transactions 
WHERE year = 2020 AND month = 7 AND day = 28 AND atm_location = 'Fifer Street';
-- id | account_number | year | month | day | atm_location | transaction_type | amount
-- 246 | 28500762 | 2020 | 7 | 28 | Fifer Street | withdraw | 48
-- 264 | 28296815 | 2020 | 7 | 28 | Fifer Street | withdraw | 20
-- 266 | 76054385 | 2020 | 7 | 28 | Fifer Street | withdraw | 60
-- 267 | 49610011 | 2020 | 7 | 28 | Fifer Street | withdraw | 50
-- 269 | 16153065 | 2020 | 7 | 28 | Fifer Street | withdraw | 80
-- 288 | 25506511 | 2020 | 7 | 28 | Fifer Street | withdraw | 20
-- 313 | 81061156 | 2020 | 7 | 28 | Fifer Street | withdraw | 30
-- 336 | 26013199 | 2020 | 7 | 28 | Fifer Street | withdraw | 35

-- Since we have some information on both some account number and licence plate I proceed by searching both joining other tables infos
-- First of all I join people table, bank account and the results from atm_transaction to retrieve people infos based on account_number
SELECT * 
FROM people 
WHERE id IN (
    SELECT person_id FROM bank_accounts WHERE account_number IN (
        SELECT account_number FROM atm_transactions WHERE year = 2020 AND month = 7 AND day = 28 AND transaction_type = 'withdraw' AND atm_location = 'Fifer Street'));
-- RESULTS:
-- id | name | phone_number | passport_number | license_plate
-- 395717 | Bobby | (826) 555-1652 | 9878712108 | 30G67EN
-- 396669 | Elizabeth | (829) 555-5269 | 7049073643 | L93JTIZ x
-- 438727 | Victoria | (338) 555-6650 | 9586786673 | 8X428L0
-- 449774 | Madison | (286) 555-6063 | 1988161715 | 1106N58
-- 458378 | Roy | (122) 555-4581 | 4408372428 | QX4YZN3
-- 467400 | Danielle | (389) 555-5198 | 8496433585 | 4328GD8 x
-- 514354 | Russell | (770) 555-1861 | 3592750733 | 322W7JE x
-- 686048 | Ernest | (367) 555-5533 | 5773159633 | 94KL13X x


-- Then I proceed searching for lincence plate obtained on the previous search matching the one mentioned on the result of 1° witness
SELECT * FROM people
-- Selecting previous license plate
WHERE people.license_plate IN (
    SELECT courthouse_security_logs.license_plate 
    FROM courthouse_security_logs 
    WHERE year = 2020 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25)
    
-- Selecting bank account number
AND people.id IN (
    SELECT person_id FROM bank_accounts
    JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
    WHERE atm_transactions.year = 2020 AND atm_transactions.month = 7 AND atm_transactions.day = 28
    AND transaction_type = 'withdraw'
    AND atm_transactions.atm_location = 'Fifer Street');
-- RESULTS
-- id | name | phone_number | passport_number | license_plate
-- 396669 | Elizabeth | (829) 555-5269 | 7049073643 | L93JTIZ
-- 467400 | Danielle | (389) 555-5198 | 8496433585 | 4328GD8
-- 514354 | Russell | (770) 555-1861 | 3592750733 | 322W7JE
-- 686048 | Ernest | (367) 555-5533 | 5773159633 | 94KL13X

-- The people are reduced to 4 but still not enough to know the thief, 
-- I proceed searcing the airport and then the flight to compare later passport number and one of those four who took a flight next day
SELECT * FROM flights WHERE origin_airport_id IN 
    (SELECT id FROM airports WHERE city = 'Fiftyville')
AND year = 2020 AND month = 7 AND day = 29;
-- Results achived
-- Flight ID: 36
-- Destination airport ID: 4
-- Departure time: 8:20

-- I now proceed searching for the thief name joining the previous results and the passport number with flight results
SELECT * FROM people
-- Selecting previous license plate
WHERE people.license_plate IN (
    SELECT courthouse_security_logs.license_plate 
    FROM courthouse_security_logs 
    WHERE year = 2020 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25)
    
-- Selecting bank account number
AND people.id IN (
    SELECT person_id FROM bank_accounts
    JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
    WHERE atm_transactions.year = 2020 AND atm_transactions.month = 7 AND atm_transactions.day = 28
    AND transaction_type = 'withdraw'
    AND atm_transactions.atm_location = 'Fifer Street')
    
-- Selecting passport number in flights
AND people.passport_number IN (
    SELECT passport_number FROM passengers
    WHERE flight_id IN (
        SELECT id FROM flights WHERE year = 2020 AND month = 7 AND day = 29
        ORDER BY hour, minute ASC LIMIT 1));
-- RESULTS
-- id | name | phone_number | passport_number | license_plate
-- 467400 | Danielle | (389) 555-5198 | 8496433585 | 4328GD8
-- 686048 | Ernest | (367) 555-5533 | 5773159633 | 94KL13X

-- Next I need to search for phone number to know the thief name between the last two person
SELECT * FROM phone_calls 
WHERE year = 2020 AND month = 7 AND day = 28 AND duration < 60;

-- I then join the last results with these one
SELECT * FROM people
-- Selecting previous license plate
WHERE people.license_plate IN (
    SELECT courthouse_security_logs.license_plate 
    FROM courthouse_security_logs 
    WHERE year = 2020 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25)
    
-- Selecting bank account number
AND people.id IN (
    SELECT person_id FROM bank_accounts
    JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
    WHERE atm_transactions.year = 2020 AND atm_transactions.month = 7 AND atm_transactions.day = 28
    AND transaction_type = 'withdraw'
    AND atm_transactions.atm_location = 'Fifer Street')
    
-- Selecting passport number in flights
AND people.passport_number IN (
    SELECT passport_number FROM passengers
    WHERE flight_id IN (
        SELECT id FROM flights WHERE year = 2020 AND month = 7 AND day = 29
        ORDER BY hour, minute ASC LIMIT 1))

-- Selecting phone number
AND people.phone_number IN (
    SELECT caller FROM phone_calls 
    WHERE year = 2020 AND month = 7 AND day = 28 AND duration < 60);
-- RESULT: THIEF NAME ERNEST
-- 686048 | Ernest | (367) 555-5533 | 5773159633 | 94KL13X

-- Thanks to previous researches we can easily know where he eascaped
SELECT * FROM airports WHERE id = 4;
-- RESULT: CITY WHERE HE ESCAPED LONDON

-- Thanks to previous searches here as well we can find his accomplice searching for phone number, day, duration of the call
SELECT * FROM people
-- Using their phone number
WHERE phone_number IN (
    -- From the list of phone calls
    SELECT receiver FROM phone_calls
    -- On the date of the crime
    WHERE year = 2020 AND month = 7 AND day = 28
    -- And where the caller was our criminal
    AND caller = (
        -- Ernest is a prick
        SELECT phone_number FROM people WHERE name = "Ernest"
    )
    -- And to reduce the likelihood of getting more than one result, let's constrain it a little more
    AND duration < 60);