# A program that calculates the minimum number of coins required to give a user change

from cs50 import get_float

# User input, positive number
while True:
    change = get_float("Change owed: ")
    if change >= 0:
        break
    
# Converting input to dollars
change *= 100

# Variable to count coins
coins = 0
    
while change >= 25:
    change -= 25
    coins += 1
while change >= 10:
    change -= 10
    coins += 1
while change >= 5:
    change -= 5
    coins += 1
while change >= 1:
    change -= 1
    coins += 1
    
# Print numbers of coins owed
print(f"{coins}")
