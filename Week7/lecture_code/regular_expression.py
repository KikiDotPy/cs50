import csv
import re

counter = 0

with open("filename.csv") as file:
  reader = csv.DictReader(file)
  for row in reader:
    title = row["title"].strip().upper()
    if re.search("^(OFFICE|THE.OFFICE)$", title):
      counter += 1
      
print(f"Number of people who like The Office: {counter}")
