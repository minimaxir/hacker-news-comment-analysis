hacker-news-comment-analysis
============================

Code used for analysis of Hacker News comments. Code is a supplement to my blog post [The Quality, Popularity, and Negativity of 5.6 Million Hacker News Comments](http://minimaxir.com/2014/10/hn-comments-about-comments/).

NB: The R analysis of the PostgreSQL database was done using the dplyr package, which has native compatibility with PostgreSQL. The reason I revert to raw SQL is because there are a few certain things in SQL that dplay can't do. (e.g. EXTRACT month and year from a date, SELECT an alias, etc.)
