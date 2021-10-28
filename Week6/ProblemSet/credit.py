# A program that determines whether a provided credit card number is valid according to Luhn’s algorithm

from cs50 import get_string


def main():
    
    # User input for credit card number
    credit_card = get_string("Number: ")

    digits = len(credit_card)
    check = luhn_checksum(credit_card)
    
    if check == 0:
        if (digits == 15) and (int(credit_card[0:2]) in [37, 34]):
            print("AMEX")
        elif (digits == 16) and (int(credit_card[0:2]) in range(50, 56)):
            print("MASTERCARD")
        elif (digits in [13, 16]) and (int(credit_card[:1]) == 4):
            print("VISA")
        else:
            print("INVALID")
    else:
        print("INVALID")

# Calculating checksum : if a card is TRUE or FALSE with Luhn algorithm


def luhn_checksum(card_number):
    # Get the cc as a list of number
    def digits_of(n):
        return [int(d) for d in str(n)]
    # Get a list of odd and even number starting from the end   
    digits = digits_of(card_number)
    odd_digits = digits[-1::-2]
    even_digits = digits[-2::-2]
    # Sum the odd digits and multiply every even digits * 2 and if it's >9 sum the 2 digits
    checksum = 0
    checksum += sum(odd_digits)
    for d in even_digits:
        checksum += sum(digits_of(d*2))
    return checksum % 10

    
if __name__ == "__main__":
    main()
