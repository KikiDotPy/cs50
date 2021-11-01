# A program that computes the approximate grade level needed to comprehend some text

from cs50 import get_string

# User text input
text = get_string("Text: ")

# Defining a list of sentence ending
space = ['!', ".", "?"]

# Counting letters and sentences
total_letters = 0
total_sentences = 0
for char in text:
    if char.isalpha():
        total_letters += 1
    if char in space:
        total_sentences += 1

# Counting words in text
word_list = text.split()
total_words = len(word_list)

#print(f"word: {total_words}, letters: {total_letters}, sencences: {total_sentences}")    
# Calculate average number of letters
L = (total_letters * 100) / total_words

# Calculate average number of sentences
S = (total_sentences * 100) / total_words

# ColemaN-Liau index to calculate Grade readability level
index = round(0.0588 * L - 0.296 * S - 15.8)

# Printing the results
if index > 16:
    print("Grade 16+")
elif index < 1:
    print("Before Grade 1")
else:
    print(f"Grade {index}")
