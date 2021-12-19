# A program that identifies a person based on their DNA
import csv
import sys

# Checking the right user prompt
if len(sys.argv) != 3:
    print("Usage: dna.py database.csv sequence.txt")
    sys.exit(1)

# Creating variables containing file names from command line arguments
csv_filename = sys.argv[1]
dna_filename = sys.argv[2]

# Open .csv file and read into memory as a list of dictionary

with open(csv_filename) as csvfile:
    reader = csv.DictReader(csvfile)
    people_data = list(reader)
 
# Open dna file and read into memory

with open(dna_filename) as dna_file:
    dna = dna_file.read()
    
# Counting the longest run of consecutive repeats of the STRs in dna.txt
# List to store max consecutive sequence of each STR
max_str = list()

# Loop through STRs in header csv file and store their count in max_str
for i in range(1, len(reader.fieldnames)):
    STR = reader.fieldnames[i]
    max_str.append(0)
   
    # Loop through dna to find STR
    for j in range(len(dna)):
        STR_count = 0
        
        # If match found, start counting repeats
        if dna[j:(j + len(STR))] == STR:
            k = 0
            while dna[(j + k):(j + k + len(STR))] == STR:
                STR_count += 1
                k += len(STR)
                    
            # If new max repeats, update max_str
            if STR_count > max_str[i - 1]:
                max_str[i - 1] = STR_count
                    
# Compare the count with the people data and print a name or Unknow it nothing found
for i in range(len(people_data)):
    matches = 0
    for j in range(1, len(reader.fieldnames)):
        if int(max_str[j - 1]) == int(people_data[i][reader.fieldnames[j]]):
            matches += 1
        if matches == (len(reader.fieldnames) - 1):
            print(people_data[i]['name'])
            exit(0)
                
print("No match")
