import csv

titles = {}

with open("filename.csv") as file:
  reader = csv.DictReader(file)
  for row in reader:
    title = row["title"].strip().upper()
    if not title in titles:
      titles[title] = 0
    titles[titles] += 1
    
for title in sorted(titles, key=lambda title: titles(title), reverse=True):
  print(title, titles[title])
