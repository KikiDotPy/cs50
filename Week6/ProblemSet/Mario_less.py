from cs50 import get_int

# Asking user input re-prompting again until h is positive and not greater than 8
while True:
    h = get_int("Height: ")
    if h > 0 and h <= 8:
        break

# Creating a pyramid of height h
for i in range(h):
    for j in range(h - 1 - i):
        print(" ", end="")
    for k in range(i + 1):
        print("#", end="")
    print("")
