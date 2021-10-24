# Words in dictionary
words = set()

def check(word):
    # Return true if word is in dictionary else false
    if word.lower() in words:
      return True
    else:
      return False

def load(dictionary):
    # Load dictionary into memory, returning true if successful else false
    file = open(dictionary, "r")
    for line in file:
        word = line.rstrip()
        words.add(word)
    file.close()
    return True

def size():
    # Return numbers of the words in dictionary
    return len(words)
