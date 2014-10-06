source("Rstart.R")
library(reshape2)

hn_comments_month <- tbl_df(read.csv("hn_comments_month.csv", header=T))
hn_comments_by_author <- tbl_df(read.csv("hn_comments_by_author.csv", header=T))
length_group <- tbl_df(read.csv("length_group.csv", header=T))
positivity_group <- tbl_df(read.csv("positivity_group.csv", header=T))
negativity_group <- tbl_df(read.csv("negativity_group.csv", header=T))
negativity_group <- tbl_df(read.csv("negativity_group.csv", header=T))
comment_points_improvement <- tbl_df(read.csv("comment_points_improvement.csv", header=T))
total_wins <- tbl_df(read.csv("total_wins.csv", header=T))
hn_comments_by_score <- tbl_df(read.csv("hn_comments_by_score.csv", header=T))
yc_search <- tbl_df(read.csv("yc_search.csv", header=T))
women_diversity <- tbl_df(read.csv("women_diversity.csv", header=T))
september_2014_hn <- tbl_df(read.csv("september_2014_hn.csv", header=T))

## Time Series

temp_data = hn_comments_month[c(-1,-nrow(hn_comments_month)),]
temp_data_size = sum(hn_comments_month[c(-1,-nrow(hn_comments_month)),]$count)

second_color <- set1_colors(0)

ggplot(aes(as.Date(date), count), data=temp_data) +
geom_line(color=second_color) +
theme_custom() +
theme(axis.title.y = element_text(color=second_color),
axis.title.x = element_text(color=second_color)) +
scale_x_date(labels=date_format("%Y")) +
scale_y_continuous(labels = comma) +
labs(x = "Date of Comment", y="# of New Comments (by Month)", title=paste("Monthly Total Comments for",format(temp_data_size, big.mark=","), "HN Comments")) +
annotate("text", x = as.Date("2014-9-9"), y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("monthly_total_comments.png", dpi=300, width=4, height=3)


second_color <- set1_colors(1)

ggplot(aes(as.Date(date), avg_comment_words), data=temp_data) +
geom_line(color=second_color) +
geom_ribbon(aes(x=as.Date(date), ymin=avg_comment_words-1.96*sd_comment_words,ymax=avg_comment_words+1.96*sd_comment_words), alpha=0.25, fill=second_color) +
theme_custom() +
theme(axis.title.y = element_text(color=second_color),
axis.title.x = element_text(color=second_color)) +
scale_x_date(labels=date_format("%Y")) + labs(x = "Date of Comment", y="Average # of Words in Comments (by Month)", title=paste("Monthly Average Words in",format(temp_data_size, big.mark=","), "HN Comments")) +
annotate("text", x = as.Date("2014-9-9"), y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("monthly_average_words.png", dpi=300, width=4, height=3)

second_color = set1_colors(2)

ggplot(aes(as.Date(date), avg_points), data=temp_data) +
geom_line(color = second_color) +
geom_ribbon(aes(x=as.Date(date), ymin=avg_points-1.96*sd_avg_points,ymax=avg_points+1.96*sd_avg_points), alpha=0.25, fill=second_color) +
theme_custom() +
theme(axis.title.y = element_text(color=second_color),
axis.title.x = element_text(color=second_color)) +
scale_x_date(labels=date_format("%Y")) +
labs(x = "Date of Comment", y="Average # of Points for Comment (by Month)", title=paste("Monthly Average Points in",format(temp_data_size, big.mark=","), "HN Comments")) +
annotate("text", x = as.Date("2014-9-9"), y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("monthly_average_points.png", dpi=300, width=4, height=3)

temp_data <- melt(temp_data %>% select(date, positivity, negativity), id.vars = "date")

ggplot(aes(x=as.Date(date), y=value, color=variable), data=temp_data) +
geom_line() +
theme_custom() +
scale_x_date(labels=date_format("%Y")) +
scale_y_continuous(labels = percent) +
labs(x = "Date of Comment", y="Average % Sentiment for Comments (by Month)", title=paste("Monthly Average Sentiment in",format(temp_data_size, big.mark=","), "HN Comments")) +
theme(legend.title = element_blank(), legend.position="top", legend.direction="horizontal", legend.key.width=unit(0.5, "cm"), legend.key.height=unit(0.25, "cm"), legend.margin=unit(-0.5,"cm"), panel.margin=element_blank(), legend.key = element_blank()) +
scale_color_manual(values=c("#2ecc71", "#e74c3c")) +
annotate("text", x = as.Date("2014-9-9"), y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("monthly_average_positive_negative.png", dpi=300, width=4, height=3)

# Comments by Score

temp_data_size = sum((hn_comments_by_score %>% filter(num_points <= 30))$count)

second_color = set1_colors(3)

ggplot(aes(x=num_points, y=count), data=hn_comments_by_score) +
geom_histogram(stat="identity", fill=second_color) +
theme_custom() +
theme(axis.title.y = element_text(color=second_color),
axis.title.x = element_text(color=second_color)) +
scale_x_continuous(limits=c(-4,30), breaks=seq(-5,30, by=5)) +
scale_y_continuous(labels = comma) +
labs(x = "# of Points of Comment", y="# of Comments w/ Point Value", title=paste("Distribution of Comment Points for",format(temp_data_size, big.mark=","), "HN Comments")) +
annotate("text", x = Inf, y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("distribution_comment_points.png",dpi=300,width=4,height=3)

temp_data_size = sum((hn_comments_by_score %>% filter(num_points <= 100))$count)

second_color = set1_colors(4)

ggplot(aes(x=num_points, y=avg_comment_words), data=hn_comments_by_score) +
geom_line(color=second_color) +
geom_ribbon(aes(x=num_points, ymin=avg_comment_words-1.96*sd_comment_words,ymax=avg_comment_words+1.96*sd_comment_words), alpha=0.25, fill=second_color) +
theme_custom() +
theme(axis.title.y = element_text(color=second_color),
axis.title.x = element_text(color=second_color)) +
scale_x_continuous(limits=c(-4,100), breaks=seq(0,100, by=10)) +
scale_y_continuous(breaks=seq(0,350, by=50)) +
labs(x = "# of Points of Comment", y="Average # of Words in Comment", title=paste("Comment Points vs. Length for",format(temp_data_size, big.mark=","), "HN Comments")) +
annotate("text", x = Inf, y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("distribution_comment_points_words.png",dpi=300,width=4,height=3)

temp_data <- melt(hn_comments_by_score %>% select(num_points, positivity, negativity), id.vars = "num_points")

ggplot(aes(x=num_points, y=value, color=variable), data=temp_data) +
geom_line() +
theme_custom() +
scale_x_continuous(limits=c(-4,100), breaks=seq(0,100, by=10)) +
scale_y_continuous(labels = percent) +
labs(x = "# of Points of Comment", y="Average % Sentiment for Comments", title=paste("Comment Points vs. Sentiment in",format(temp_data_size, big.mark=","), "HN Comments")) +
theme(legend.title = element_blank(), legend.position="top", legend.direction="horizontal", legend.key.width=unit(0.5, "cm"), legend.key.height=unit(0.25, "cm"), legend.margin=unit(-0.5,"cm"), panel.margin=element_blank(), legend.key = element_blank()) +
scale_color_manual(values=c("#2ecc71", "#e74c3c")) +
annotate("text", x = Inf, y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("distribution_comment_points_sentiment.png",dpi=300,width=4,height=3)

# Users n-th comment

temp_data <- comment_points_improvement %>% filter(num_comments <= 100)

second_color <- set1_colors(5)

ggplot(aes(x=num_comments,y=users_who_made_num_comments), data=temp_data) +
geom_bar(stat="identity", fill=second_color) +
theme_custom() +
theme(axis.title.y = element_text(color=second_color),
axis.title.x = element_text(color=second_color)) +
scale_x_continuous(limits=c(0,100), breaks=seq(0,100, by=10)) +
scale_y_continuous(breaks=seq(0,200000, by=10000), labels=comma) +
labs(x = expression(italic(n)^"th"~Comment~Made~By~User), y=expression(Number~of~Users~Who~Made~Atleast~italic(n)~Comments), title="Comment Activity for Hacker News Users") +
annotate("text", x = Inf, y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("n-comments.png",dpi=300,width=4,height=3)

temp_data <- comment_points_improvement %>% filter(num_comments <= 500)

second_color <- set1_colors(6)

ggplot(aes(x=num_comments, y=avg_points), data=temp_data) +
geom_line(color = second_color) +
geom_ribbon(aes(x=num_comments, ymin=avg_points-1.96*sd_avg_points,ymax=avg_points+1.96*sd_avg_points), alpha=0.25, fill=second_color) +
theme_custom() +
theme(axis.title.y = element_text(color=second_color),
axis.title.x = element_text(color=second_color)) +
scale_x_continuous(limits=c(-4,500), breaks=seq(0,500, by=50)) +
#scale_y_continuous(breaks=seq(0,350, by=50)) +
labs(x = expression(italic(n)^"th"~Comment~Made~By~User), y=expression(Average~Points~For~italic(n)^"th"~Comment), title="Comment Point Improvement With Practice for HN Users") +
annotate("text", x = Inf, y = -Inf, label = "max woolf — minimaxir.com",hjust=1.1, vjust=-0.5, col="#1a1a1a", family=fontFamily, alpha = 0.20, size=2)

ggsave("n-comments-practice.png",dpi=300,width=4,height=3)

# YC Search + Women Diversity
temp_means = tbl_df(data.frame(avg_pos_words = mean(september_2014_hn$avg_pos_words),avg_neg_words = mean(september_2014_hn$avg_neg_words)))
temp_means = melt(temp_means)
temp_data <- melt(september_2014_hn %>% select(id, avg_pos_words, avg_neg_words), id.vars = "id")
levels(temp_data$variable)=c("Positive Words", "Negative Words")
levels(temp_means$variable)=c("Positive Words", "Negative Words")

ggplot(aes(x=value, y=..ndensity.., fill=variable), data=temp_data) +
geom_histogram() +
geom_vline(aes(xintercept=value, color=variable), data=temp_means) +
geom_text(aes(x = value + 2, y = 0.85, label = format(value, digits=3), color=variable), size=3, family=fontTitle, data=temp_means)  +
theme_custom() +
scale_x_continuous(breaks=seq(0,10,by=2), limits=c(0,10)) +
theme(strip.background = element_rect(fill="white", color="white")) +
scale_fill_manual(values=c("#2ecc71", "#e74c3c"), guide=FALSE) +
scale_color_manual(values=c("#27ae60", "#c0392b"), guide=FALSE) + facet_wrap(~ variable, ncol=2) +
labs(x="Average # of Sentiment Words in Comments on Thread", y="Normalized Density of Sentiment Word Occurences", title="Density of Sentiment Words on September 2014 HN Articles")

ggsave("density_september_2014_hn.png", dpi=300, width=4, height=3)

temp_means = tbl_df(data.frame(avg_pos_words = mean(women_diversity$avg_pos_words),avg_neg_words = mean(women_diversity$avg_neg_words)))
temp_means = melt(temp_means)
temp_data <- melt(women_diversity %>% select(id, avg_pos_words, avg_neg_words), id.vars = "id")
levels(temp_data$variable)=c("Positive Words", "Negative Words")
levels(temp_means$variable)=c("Positive Words", "Negative Words")

ggplot(aes(x=value, y=..ndensity.., fill=variable), data=temp_data) +
geom_histogram() +
geom_vline(aes(xintercept=value, color=variable), data=temp_means) +
geom_text(aes(x = value + 2, y = 0.85, label = format(value, digits=3), color=variable), size=3, family=fontTitle, data=temp_means)  +
theme_custom() +
scale_x_continuous(breaks=seq(0,10,by=2), limits=c(0,10)) +
theme(strip.background = element_rect(fill="white", color="white")) +
scale_fill_manual(values=c("#3498db", "#f1c40f"), guide=FALSE) +
scale_color_manual(values=c("#2980b9", "#f39c12"), guide=FALSE) + facet_wrap(~ variable, ncol=2) +
labs(x="Average # of Sentiment Words in Comments on Submission", y="Normalized Density of Sentiment Word Occurences", title="Density of Sentiment Words in HN Submissions of Gen./Diversity")

ggsave("density_women.png", dpi=300, width=4, height=3)


### Wordclouds

library(wordcloud)

stop_words <- unlist(strsplit("a,able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,where,which,while,who,whom,why,will,with,would,yet,you,your,id,item, 1,2,3,4,5,6,7,8,9,ii,http,www,ycombinator,com,org,don\'t,i\'ve,i\'d,it\'s,i\'m,https,en,e,g,n,up", ","))

count_stop_words <- function(x) {
	word_array <- strsplit(as.character(x)," ")[[1]]
	 
	return (sum(word_array %in% stop_words))
}

words_2gram_yc <- tbl_df(read.csv("hn_092014_2gram.csv", header=T)) %>% filter(lapply(word, count_stop_words) < 1)

pal <- brewer.pal(9, "Oranges")
pal <- pal[-c(1:3)]
png(filename = "hn_092014_2gram.png", width = 3000, height = 3000, res= 300)

wordcloud(toupper(words_2gram_yc$word), words_2gram_yc$count, scale=c(6,.1), random.order=F, rot.per=.10, max.words=5000, colors=pal, family=fontFamily, random.color=T)

dev.off()

words_2gram_gender <- tbl_df(read.csv("hn_gender_2gram.csv", header=T)) %>% filter(lapply(word, count_stop_words) < 1)

pal <- brewer.pal(9, "Purples")
pal <- pal[-c(1:3)]
png(filename = "hn_gender_2gram.png", width = 3000, height = 3000, res= 300)

wordcloud(toupper(words_2gram_gender$word), words_2gram_gender$count, scale=c(6,.1), random.order=F, rot.per=.10, max.words=5000, colors=pal, family=fontFamily, random.color=T)

dev.off()
