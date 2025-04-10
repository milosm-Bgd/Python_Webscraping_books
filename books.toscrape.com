import requests

res = requests.get("http://www.example.com")

type(res)

res.text

#importing the entire moduel 
import bs4  #BeautifulSoup library 
#using BeautifulSoup we can create a "soup" object that contains all the "ingredients" of the webpage.

#import just the class that we need
#we go with this approach 
from bs4 import BeautifulSoup 

# BeautifulSoup(MARKUP, HTML PARSER)
# OPtions for PArser: 
#1. "html.parser" (Python's html parser)
#2. "lxml" (lxml's HTML parser)
#3. "lxml-xml" (lxml's XML parser)
#4 "html5lib" (html5lib)

soup = bs4.BeautifulSoup(res.text, "lxml") #can be applied also without bs4 .notation

print(soup) # because we already imported 'bs4' library above  

Tag

#now let's use the .select() method to grab elements. We are lookong for the 'title' 
soup.select('title')

soup.select('title')

soup.select('p')

title_tag = soup.select('title')
title_tag[0]   #isolating the first tag element out of the list from above []
# its a object of class Tag 

type(title_tag[0])

title_tag[0].getText()

#let's gt the first <p></p> tag 
p1 = soup.select('p')[0]
type(p1)

p1.getText()

CLASS (but as an attribute of a HTML Tag)

#First get the request
res = requests.get('https://en.wikipedia.org/wiki/Grace_Hopper')

#Create a soup from requests
soup = bs4.BeautifulSoup(res.text, "lxml") 


soup.select('div')

soup.select('span')

soup.select('.vector-toc-text')

type(soup.select('.vector-toc-text'))


for item in soup.select('.toctext'):
  print(item.text)

for item in soup.select('.vector-toc-text'):
    print(item.text)

Example Project - Web Scraping Multiple

# http://books.toscrape.com/catalogue/page-1.html
base_url = 'http://books.toscrape.com/catalogue/page-{}.html'
type(base_url)

base_url.format('1')

res = requests.get(base_url.format('1'))
soup = BeautifulSoup(res.text,"lxml")
soup

soup.select(".product_pod")

products = soup.select(".product_pod")

example = products[0]

example

type(example)

example.attrs

list(example.children)

#what if a given tag has more than just one class?
example.select('.star-rating.Three')

#but we are looking for 2 stars, so it looks like we can just check to see if 
#somethign was returned 
example.select('.star-rating.Two')

example.select('a')

example.select('a')[1]['title']

# An Example for Homework
# Scrape just the Books with 2 stars Rating
# Note two_star_titles = [] that right from the start, we know that there are 50 pages
two_star_titles = []

base_url = 'https://books.toscrape.com/catalogue/page-{}.html'

for n in range(1,51):

  scrape_url = base_url.format(n)
  res = requests.get(scrape_url)
  
  soup = BeautifulSoup(res.text, "lxml")
  books = soup.select('.product_pod')

  for book in books:
    if len(book.select('.star-rating.Two')) != 0:
      two_star_titles.append(book.select('a')[1]['title'])

two_star_titles

# Let us define the Class that we will use
# Q: What does the method "__repr__" stand for?
class Book():
    def __init__(self, title, price):
        self.title = title
        self.price = price
    
    def __repr__(self):
        return f'Book({self.title}, {self.price}£)'
    

scrape_url = base_url.format('1')
res = requests.get(scrape_url)
soup = BeautifulSoup(res.text, "lxml")

soup

books = soup.select('.product_pod')

books

books[0]

float(books[0].select('.price_color')[0].getText().split('£')[1])

def get_price(price_as_text, split_char):
    price = price_as_text.split(split_char)[1]
    print(price_as_text.split(split_char))
    return float(price)

get_price('other_text£12.17', '£')

books[0].select('a')[1]['title']

#go up/down
books[0].select('h3')[0].parent

#MAIN TAKE_AWAY FORM THE LESSONS
import time

has_next = True
n=1
all_books = []

while(has_next):
    
    scrape_url = base_url.format(n)
    res = requests.get(scrape_url)
    
    soup = BeautifulSoup(res.text,"lxml")
    
    books = soup.select(".product_pod")
    print(f'There are {len(books)} books on page {n}.)
    
    for book in books: 
          title = book.select('a')[1].getText()
           # title = book.select('a')[1]['title']
          price = float(book.select('.price_color')[0].getText().split('£')[1])
          # price = get_price(book.select('.price_color')[0].getText(), '£')
          print(title, price)
          book_object = Book(title,price)
          all_books.append(book_object)
          
    has_next_button_list = soup.select(".next")
    #print(has_next_button_list)
    if not has_next_button_list:    #if len(has_next_button_list) = 0
          has_next = False
          print('Loop is over')
    else:
          print('Continue to next page:' ,n)
          
    n=+1
    time.sleep(0.5)  # delay for 0.5 seconds
    