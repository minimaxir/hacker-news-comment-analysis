source("Rstart.R")

con <- src_postgres(dbname = "hacker_news", host="localhost", port="5432", user="postgres", password="1234")

hn_comments <- tbl(con, "hn_comments")
hn_comments_head <- head(hn_comments)

hn_comments_month <- tbl(con, sql("
SELECT EXTRACT(MONTH FROM created_at) as month,
EXTRACT(YEAR FROM created_at) AS year,
COUNT(created_at) AS count,
AVG(LENGTH(comment_text))/5.1 AS avg_comment_words,
STDDEV(LENGTH(comment_text)/5.1) / SQRT(COUNT(created_at)) AS sd_comment_words,
AVG(num_points) AS avg_points,
STDDEV(num_points) / SQRT(COUNT(created_at)) AS sd_avg_points,
AvG(num_pos_words) AS avg_pos_words,
AvG(num_neg_words) AS avg_neg_words
FROM hn_comments
GROUP BY month, year
ORDER BY year, month"))
hn_comments_month <- tbl_df(collect(hn_comments_month))
hn_comments_month <- hn_comments_month %>% mutate(positivity = avg_pos_words / avg_comment_words, negativity = avg_neg_words / avg_comment_words, date = paste(year,month,"01",sep="-"))

# write.csv(hn_comments_month,"hn_comments_month.csv", row.names=F)
# hn_comments_month <- tbl_df(read.csv("hn_comments_month.csv",header=T))

hn_comments_by_score <- tbl(con, sql("
SELECT num_points,
COUNT(num_points) AS count,
AVG(LENGTH(comment_text))/5.1 AS avg_comment_words,
STDDEV(LENGTH(comment_text)/5.1) / SQRT(COUNT(num_points)) AS sd_comment_words,
AvG(num_pos_words) AS avg_pos_words,
AvG(num_neg_words) AS avg_neg_words
FROM hn_comments
GROUP BY num_points
HAVING COUNT(num_points) > 30
ORDER BY num_points ASC"))
hn_comments_by_score <- tbl_df(collect(hn_comments_by_score))
hn_comments_by_score <- hn_comments_by_score %>% mutate(positivity = avg_pos_words / avg_comment_words, negativity = avg_neg_words / avg_comment_words)

# write.csv(hn_comments_by_score,"hn_comments_by_score.csv", row.names=F)
# hn_comments_by_score <- tbl_df(read.csv("hn_comments_by_score.csv",header=T))

cor(hn_comments_by_score[,-1])
#AVG(LENGTH(comment_text))/5.1 AS avg_comment_words,

least_comment_points <- tbl(con, sql("
SELECT comment_text,
author,
num_points,
num_pos_words,
num_neg_words,
EXTRACT(MONTH FROM created_at) as month,
EXTRACT(YEAR FROM created_at) AS year,
objectID
FROM (
SELECT comment_text,
author,
num_points,
num_pos_words,
num_neg_words,
created_at,
objectID, 
ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM created_at), EXTRACT(YEAR FROM created_at) ORDER BY num_points ASC) AS pos
FROM hn_comments
) AS ss
WHERE pos=1
ORDER BY year, month"))

least_comment_points <- tbl_df(collect(least_comment_points))
write.csv(least_comment_points,"hn_least_comment_points.csv", row.names=F)

most_comment_points <- tbl(con, sql("
SELECT comment_text,
author,
num_points,
num_pos_words,
num_neg_words,
EXTRACT(MONTH FROM created_at) as month,
EXTRACT(YEAR FROM created_at) AS year,
objectID
FROM (
SELECT comment_text,
author,
num_points,
num_pos_words,
num_neg_words,
created_at,
objectID, 
ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM created_at), EXTRACT(YEAR FROM created_at) ORDER BY num_points DESC) AS pos
FROM hn_comments
) AS ss
WHERE pos=1
ORDER BY year, month"))

most_comment_points <- tbl_df(collect(most_comment_points))
write.csv(most_comment_points,"hn_most_comment_points.csv", row.names=F)


### By Author

hn_comments_by_author <- tbl(con, sql("
SELECT author,
COUNT(author) AS count,
AVG(num_points) AS avg_points,
AVG(LENGTH(comment_text))/5.1 AS avg_comment_words,
AvG(num_pos_words) AS avg_pos_words,
AvG(num_neg_words) AS avg_neg_words
FROM hn_comments
GROUP BY author
HAVING COUNT(author) > 30
ORDER BY avg_points DESC"))
hn_comments_by_author <- tbl_df(collect(hn_comments_by_author))
hn_comments_by_author <- hn_comments_by_author %>% mutate(positivity = avg_pos_words / avg_comment_words, negativity = avg_neg_words / avg_comment_words)

# write.csv(hn_comments_by_author,"hn_comments_by_author.csv", row.names=F)
# hn_comments_by_author <- tbl_df(read.csv("hn_comments_by_author.csv",header=T))

cor(hn_comments_by_score[,-1])


length_group <- tbl(con, sql("
SELECT LENGTH(comment_text)/5.1 AS comment_words,
COUNT(comment_text) AS count
FROM hn_comments
GROUP BY comment_words
ORDER BY comment_words"))

length_group <- tbl_df(collect(length_group))

# write.csv(length_group,"length_group.csv", row.names=F)
# length_group <- tbl_df(read.csv("length_group.csv",header=T))


positivity_group <- tbl(con, sql("
SELECT ROUND(num_pos_words / (LENGTH(comment_text)/5.1), 2) AS positivity,
COUNT(comment_text) AS count
FROM hn_comments
WHERE LENGTH(comment_text) > 0
GROUP BY positivity
ORDER BY positivity"))

positivity_group <- tbl_df(collect(positivity_group))

# write.csv(positivity_group,"positivity_group.csv", row.names=F)
# positivity_group <- tbl_df(read.csv("positivity_group.csv",header=T))

negativity_group <- tbl(con, sql("
SELECT ROUND(num_neg_words / (LENGTH(comment_text)/5.1), 2) AS negativity,
COUNT(comment_text) AS count
FROM hn_comments
WHERE LENGTH(comment_text) > 0
GROUP BY negativity
ORDER BY negativity"))

negativity_group <- tbl_df(collect(negativity_group))

# write.csv(negativity_group,"negativity_group.csv", row.names=F)
# negativity_group <- tbl_df(read.csv("negativity_group.csv",header=T))


### Thread_Winners

thread_wins<- tbl(con, sql("
SELECT
author,
COUNT(story_id) AS thread_wins
FROM (
SELECT 
author,
story_id,
RANK() OVER (PARTITION BY story_id ORDER BY num_points DESC) AS pos
FROM hn_comments
WHERE num_points >= 5
) AS ss
WHERE pos=1
GROUP BY author
ORDER BY thread_wins DESC
LIMIT 1000"))

thread_wins <- tbl_df(collect(thread_wins))
#write.csv(thread_wins,"thread_wins.csv", row.names=F)

commenters_total_karma <- tbl(con, sql("
SELECT
author,
SUM(num_points) AS total_comment_karma,
MAX(created_at) AS last_comment
FROM hn_comments
GROUP BY author
ORDER BY total_comment_karma DESC
LIMIT 1000"))

commenters_total_karma <- tbl_df(collect(commenters_total_karma))

total_wins <- inner_join(thread_wins,commenters_total_karma) %>% mutate(wins_karma_ratio = total_comment_karma / thread_wins) %>% arrange(desc(thread_wins))
write.csv(total_wins,"total_wins.csv", row.names=F)


### Writing Skill Over Time

comment_points_improvement <- tbl(con, sql("
SELECT
num_comments,
COUNT(num_points) AS users_who_made_num_comments,
AVG(num_points) AS avg_points,
STDDEV(num_points) / SQRT(COUNT(num_points)) AS sd_avg_points,
AVG(cum_sum_points) AS avg_total_points
FROM (
SELECT 
author,
num_points,
ROW_NUMBER() OVER (PARTITION BY author ORDER BY created_at ASC) AS num_comments,
SUM(num_points) OVER (PARTITION BY author ORDER BY created_at ASC) AS cum_sum_points
FROM hn_comments
) AS ss
GROUP BY num_comments
ORDER BY num_comments"))

comment_points_improvement <- tbl_df(collect(comment_points_improvement))
write.csv(comment_points_improvement,"comment_points_improvement.csv", row.names=F)

### Search for Diversity

yc_search <- tbl(con, sql("
SELECT
hn_submissions_filtered.objectID AS id,
hn_submissions_filtered.title AS title,
AVG(hn_comments.num_points) AS avg_comment_points,
AVG(hn_comments.num_pos_words) AS avg_pos_words,
AVG(hn_comments.num_neg_words) AS avg_neg_words
FROM hn_comments, (SELECT objectID, title FROM hn_submissions WHERE hn_submissions.title LIKE \'%YC ___%\'
) as hn_submissions_filtered WHERE hn_comments.story_id = hn_submissions_filtered.objectID
GROUP BY id, title"))

system.time(yc_search <- tbl_df(collect(yc_search)) %>% filter(avg_comment_points > 1))
write.csv(yc_search,"yc_search.csv", row.names=F)

women_diversity <- tbl(con, sql("
SELECT
hn_submissions_filtered.objectID AS id,
hn_submissions_filtered.title AS title,
AVG(hn_comments.num_points) AS avg_comment_points,
AVG(hn_comments.num_pos_words) AS avg_pos_words,
AVG(hn_comments.num_neg_words) AS avg_neg_words
FROM hn_comments, (SELECT objectID, title FROM hn_submissions
WHERE LOWER(title) LIKE \'%women%\' OR LOWER(title) LIKE \'%diversity%\' OR LOWER(title) LIKE \'%female%\' 
) as hn_submissions_filtered WHERE hn_comments.story_id = hn_submissions_filtered.objectID
GROUP BY id, title"))

system.time(women_diversity <- tbl_df(collect(women_diversity)) %>% filter(avg_comment_points > 1))

write.csv(women_diversity,"women_diversity.csv", row.names=F)

september_2014 <- tbl(con, sql("
SELECT
hn_submissions_filtered.objectID AS id,
hn_submissions_filtered.title AS title,
hn_submissions_filtered.created_at AS date,
AVG(hn_comments.num_points) AS avg_comment_points,
AVG(hn_comments.num_pos_words) AS avg_pos_words,
AVG(hn_comments.num_neg_words) AS avg_neg_words
FROM hn_comments, (SELECT objectID, title, created_at FROM hn_submissions
WHERE created_at >= \'2014-09-01 00:00:00\' AND created_at < \'2014-10-01 00:00:00\'
) as hn_submissions_filtered WHERE hn_comments.story_id = hn_submissions_filtered.objectID
GROUP BY id, title, date"))

system.time(september_2014 <- tbl_df(collect(september_2014)) %>% filter(avg_comment_points > 1))

write.csv(september_2014,"september_2014_hn.csv", row.names=F)
