-- Keep a log of any SQL queries you execute as you solve the mystery.
-- The crime took place on July 28, 2020 on Chamberlin Street.

-- I search through the crime reports to gather more infos about the crime
SELECT * FROM crime_scene_reports 
WHERE year = 2020 AND month = 7 AND day = 28;
-- RESULT:
-- 295 | 2020 | 7 | 28 | Chamberlin Street | Theft of the CS50 duck took place at 10:15am 
-- at the Chamberlin Street courthouse. Interviews were conducted today with three witnesses 
-- who were present at the time — each of their interview transcripts mentions the courthouse.

-- In the crime report is mentioned the theft time (10:15am) and that there are 3 witnesses 
-- I then search in the interviews database with COURTHOUSE keyword on the crime day for witnesses report
SELECT * FROM interviews 
WHERE transcript LIKE "%courthouse%"" 
AND year = 2020 AND month = 7 AND day = 28;
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

-- All 3 witnesses reports need further investigation

-- 1° WITNESS REPORT
-- I search for the car mentioned in the time window between 10:15 and 10:25 to retrieve LICENSE PLATE
SELECT * FROM courthouse_security_logs 
WHERE year = 2020 AND month = 7 AND day = 28 AND hour = 10 
AND minute BETWEEN 15 AND 25;
-- RESULTs:
-- 260 | 2020 | 7 | 28 | 10 | 16 | exit | 5P2BI95
-- 261 | 2020 | 7 | 28 | 10 | 18 | exit | 94KL13X 
-- 262 | 2020 | 7 | 28 | 10 | 18 | exit | 6P58WS2
-- 263 | 2020 | 7 | 28 | 10 | 19 | exit | 4328GD8 
-- 264 | 2020 | 7 | 28 | 10 | 20 | exit | G412CB7
-- 265 | 2020 | 7 | 28 | 10 | 21 | exit | L93JTIZ 
-- 266 | 2020 | 7 | 28 | 10 | 23 | exit | 322W7JE 
-- 267 | 2020 | 7 | 28 | 10 | 23 | exit | 0NTHK55

-- 2° WITNESS REPORT
-- I search on ATM logs on the street mentioned, specifying crime date and transaction type also mentioned by witness to retrieve bank account number
SELECT * FROM atm_transactions 
WHERE year = 2020 AND month = 7 AND day = 28 
AND atm_location = "Fifer Street"
AND transaction_type = "withdraw";
-- RESULTs:
-- id | account_number | year | month | day | atm_location | transaction_type | amount
-- 246 | 28500762 | 2020 | 7 | 28 | Fifer Street | withdraw | 48
-- 264 | 28296815 | 2020 | 7 | 28 | Fifer Street | withdraw | 20
-- 266 | 76054385 | 2020 | 7 | 28 | Fifer Street | withdraw | 60
-- 267 | 49610011 | 2020 | 7 | 28 | Fifer Street | withdraw | 50
-- 269 | 16153065 | 2020 | 7 | 28 | Fifer Street | withdraw | 80
-- 288 | 25506511 | 2020 | 7 | 28 | Fifer Street | withdraw | 20
-- 313 | 81061156 | 2020 | 7 | 28 | Fifer Street | withdraw | 30
-- 336 | 26013199 | 2020 | 7 | 28 | Fifer Street | withdraw | 35

-- 3° WITNESS REPORT
-- I search both on phone calls to retrieve phone number and flights to know the earliest next day flight.
-- This way I can have both destination city and passport number.
SELECT * FROM phone_calls
WHERE year = 2020 AND month = 7 AND day = 28
AND duration < 60;
-- RESULTs:
-- id | caller | receiver | year | month | day | duration
-- 221 | (130) 555-0289 | (996) 555-8899 | 2020 | 7 | 28 | 51
-- 224 | (499) 555-9472 | (892) 555-8872 | 2020 | 7 | 28 | 36
-- 233 | (367) 555-5533 | (375) 555-8161 | 2020 | 7 | 28 | 45
-- 251 | (499) 555-9472 | (717) 555-1342 | 2020 | 7 | 28 | 50
-- 254 | (286) 555-6063 | (676) 555-6554 | 2020 | 7 | 28 | 43
-- 255 | (770) 555-1861 | (725) 555-3243 | 2020 | 7 | 28 | 49
-- 261 | (031) 555-6622 | (910) 555-3251 | 2020 | 7 | 28 | 38
-- 279 | (826) 555-1652 | (066) 555-9701 | 2020 | 7 | 28 | 55
-- 281 | (338) 555-6650 | (704) 555-2131 | 2020 | 7 | 28 | 54
SELECT * FROM flights
WHERE year = 2020 AND month = 7 AND day = 29
ORDER BY hour, minute ASC LIMIT 1;
-- RESULT:
-- id | origin_airport_id | destination_airport_id | year | month | day | hour | minute
-- 36 | 8 | 4 | 2020 | 7 | 29 | 8 | 20

-- I can now try to retrieve the thief name by crossing the 3 witnesses information obtained: 
-- the license plate number, bank account number, phone number and the passport number.
SELECT * FROM people
-- Query courthouse security logs table for license plate
WHERE people.license_plate IN (
    SELECT license_plate FROM courthouse_security_logs
    WHERE year = 2020 AND month = 7 AND day = 28 AND hour = 10 AND minute BETWEEN 15 AND 25)
-- Query ATM transactions and bank accounts tables for bank account number
AND people.id IN (
    SELECT person_id FROM bank_accounts
    JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
    WHERE atm_transactions.year = 2020 AND atm_transactions.month = 7 AND atm_transactions.day = 28
    AND transaction_type = "withdraw"
    AND atm_transactions.atm_location = "Fifer Street")
-- Query phone calls table for phone number
AND people.phone_number IN (
    SELECT caller FROM phone_calls
    WHERE year = 2020 AND month = 7 AND day = 28
    AND duration < 60)
-- Query flights and passengers tables for passport number
AND people.passport_number IN (
    SELECT passport_number FROM passengers
    WHERE flight_id IN (
        SELECT id FROM flights WHERE year = 2020 AND month = 7 AND day = 29
        ORDER BY hour, minute ASC LIMIT 1));
-- RESULT
-- id | name | phone_number | passport_number | license_plate
-- 686048 | Ernest | (367) 555-5533 | 5773159633 | 94KL13X

-- THIEF NAME - ERNEST


-- Thanks to previous searches, we can easily know the city where the thief eascaped
SELECT * FROM airports WHERE id = 4;
-- RESULT:
-- id | abbreviation | full_name | city
-- 4 | LHR | Heathrow Airport | London

-- CITY WHERE THE THIEF ESCAPED - LONDON


-- I just need to find the accomplice's name by looking further in the phone_calls table
-- I search again by adding to the previous search the thief name and his phone number:

SELECT * FROM people
WHERE phone_number IN (
    SELECT receiver FROM phone_calls
    WHERE year = 2020 AND month = 7 AND day = 28
    AND caller = (
        SELECT phone_number FROM people WHERE name = "Ernest")
    AND duration < 60);
-- RESULT:
-- id | name | phone_number | passport_number | license_plate
-- 864400 | Berthold | (375) 555-8161 |  | 4V16VO0

-- ACCOMPLICE'S NAME BERTHOLD