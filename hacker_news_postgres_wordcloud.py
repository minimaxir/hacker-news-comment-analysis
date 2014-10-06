import urllib2
import json
import datetime
import time
import pytz
import psycopg2
import re
import HTMLParser
import csv


# From http://locallyoptimal.com/blog/2013/01/20/elegant-n-gram-generation-in-python/
def find_ngrams(input_list, n):
  return zip(*[input_list[i:] for i in range(n)])
  
words_2gram =  {}
words_3gram =  {}
pattern = re.compile("[^\w']")

host = "localhost"
dbname = "hacker_news"
user = "postgres"
password = "1234"

 
conn_string = "host=%s dbname=%s user=%s password=%s" % (host, dbname, user, password)
db = psycopg2.connect(conn_string)
cur = db.cursor()

### Process September 2014 Data

query = "SELECT hn_comments.comment_text FROM hn_comments, (SELECT objectID, title FROM hn_submissions WHERE created_at >= \'2014-09-01 00:00:00\' AND created_at < \'2014-10-01 00:00:00\') as hn_submissions_filtered WHERE hn_comments.story_id = hn_submissions_filtered.objectID"


print "Executing Query."
cur.execute(query)
print "Query Complete!."

i = 0

for comment in cur:	
	try:
		text = comment[0].encode('utf-8').lower()
		text_tokens = pattern.sub(' ', text).split()
		
		text_tokens_2gram = find_ngrams(text_tokens, 2)
		text_tokens_3gram = find_ngrams(text_tokens, 3)
			
		for word in text_tokens_2gram:
			if word not in words_2gram:
				words_2gram[word] = 1
			else:
				words_2gram[word] += 1	
							
		for word in text_tokens_3gram:
			if word not in words_3gram:
				words_3gram[word] = 1
			else:
				words_3gram[word] += 1	

		i += 1
		if i % 1000 == 0:
			print i
	except Exception, e:
		print e

with open('hn_092014_2gram.csv', 'wb') as file:
	w = csv.writer(file)
	w.writerow(['word','count'])
	for word, count in words_2gram.items():
		if count > 50:
			w.writerow([' '.join(word), count])
			
with open('hn_092014_3gram.csv', 'wb') as file:
	w = csv.writer(file)
	w.writerow(['word','count'])
	for word, count in words_3gram.items():
		if count > 50:
			w.writerow([' '.join(word), count])
			
### Process YC Data


words_2gram =  {}
words_3gram =  {}
query = "SELECT hn_comments.comment_text FROM hn_comments, (SELECT objectID, title FROM hn_submissions WHERE LOWER(title) LIKE \'%women%\' OR LOWER(title) LIKE \'%diversity%\' OR LOWER(title) LIKE \'%female%\') as hn_submissions_filtered WHERE hn_comments.story_id = hn_submissions_filtered.objectID"


print "Executing Query."
cur.execute(query)
print "Query Complete!."

i = 0

for comment in cur:	
	try:
		text = comment[0].encode('utf-8').lower()
		text_tokens = pattern.sub(' ', text).split()
		
		text_tokens_2gram = find_ngrams(text_tokens, 2)
		text_tokens_3gram = find_ngrams(text_tokens, 3)
			
		for word in text_tokens_2gram:
			if word not in words_2gram:
				words_2gram[word] = 1
			else:
				words_2gram[word] += 1	
							
		for word in text_tokens_3gram:
			if word not in words_3gram:
				words_3gram[word] = 1
			else:
				words_3gram[word] += 1	

		i += 1
		if i % 1000 == 0:
			print i
	except Exception, e:
		print e

with open('hn_gender_2gram.csv', 'wb') as file:
	w = csv.writer(file)
	w.writerow(['word','count'])
	for word, count in words_2gram.items():
		if count > 50:
			w.writerow([' '.join(word), count])
			
with open('hn_gender_3gram.csv', 'wb') as file:
	w = csv.writer(file)
	w.writerow(['word','count'])
	for word, count in words_3gram.items():
		if count > 50:
			w.writerow([' '.join(word), count])