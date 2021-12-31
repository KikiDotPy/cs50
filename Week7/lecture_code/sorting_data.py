import csv

titles = set()

with open("filename.csv") as file:
  reader = csv.DictReader(file)
  for row in reader:
    title = row["title"].strip().upper()
    titles.add(title)
    
for title in sorted(titles):
  print(title)
