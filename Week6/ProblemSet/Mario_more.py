from cs50 import get_int

# User input from 1 to 8, re-prompting if not in that range
while True:
    h = get_int("Height: ")
    if h > 0 and h < 9:
        break
    
# Column
for i in range(h):
    
    # Starting spaces to allign on the right
    for k in range(h - 1 - i):
        print(" ", end="")
    
    # Row
    for j in range(i + 1):
        print("#", end="")
    print("  ", end="")
    
    # Second Pyramid
    for y in range(i + 1):
        print("#", end="")
    print("")
