# Uppercases string one character at a time

from cs50 import get_string

s = get_string("Before: ")
print("After:  ", end="")
for c in s:
    print(c.upper(), end="")
print()



# Uppercases string all at once
from cs50 import get_string

s = get_string("Before: ")
print(f"After:  {s.upper()}")
