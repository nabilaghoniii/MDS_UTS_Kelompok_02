# Create API Database ElephantSQL 

library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")


con <- dbConnect(drv,
                 dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"), 
                 host = Sys.getenv("ELEPHANT_SQL_HOST"),
                 port = 5432,
                 user = Sys.getenv("ELEPHANT_SQL_USER"),
                 password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)

# Get Latest Data
latest_entry <- 'SELECT * FROM "public"."UpdateTreasury" LIMIT 1'

df_latest <- dbGetQuery(con, latest_entry)

df_chart <- as.data.frame(matrix(, nrow = 12, ncol = 2))
colnames(df_chart) <- c("x", "y")
df_chart[1,] <- cbind(1/12, df_latest$X1.Mo)
df_chart[2,] <- cbind(2/12, df_latest$X2.Mo)
df_chart[3,] <- cbind(3/12, df_latest$X3.Mo)
df_chart[4,] <- cbind(6/12, df_latest$X6.Mo)
df_chart[5,] <- cbind(1, df_latest$X1.Yr)
df_chart[6,] <- cbind(2, df_latest$X2.Yr)
df_chart[7,] <- cbind(3, df_latest$X3.Yr)
df_chart[8,] <- cbind(5, df_latest$X5.Yr)
df_chart[9,] <- cbind(7, df_latest$X7.Yr)
df_chart[10,] <- cbind(10, df_latest$X10.Yr)
df_chart[11,] <- cbind(20, df_latest$X20.Yr)
df_chart[12,] <- cbind(30, df_latest$X30.Yr)


# Latest Status
status_details <- paste0(
  "Hello, World!", 
  "\n", 
  "\n",
  "This is a test tweet for the latest US Treasury Par Yield Curve:", "\n",
  "Date as of: ", df_latest$Date, "\n",
  "UST 02-year: ", df_latest$X2.Yr, "\n",
  "UST 05-year: ", df_latest$X5.Yr, "\n",
  "UST 10-year: ", df_latest$X10.Yr, "\n",
  "UST 20-year: ", df_latest$X20.Yr, "\n",
  "UST 30-year: ", df_latest$X30.Yr, "\n",
  "\n",
  "\n"
  )

# Latest Chart
library(ggplot2)
pic <- ggplot(df_chart) +
  aes(x = x, y = y) +
  geom_point(
    shape = "circle",
    size = 1.35,
    colour = "#112446"
  ) +
  geom_smooth(span = 0.5) +
  labs(
    x = "Tenor (year)",
    y = "Yield (in %)",
    title = "US Treasury Yield Curve"
  ) +
  theme_linedraw() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

pic_file <- tempfile( fileext = ".png")
ggsave(pic_file, plot = pic, device = "png", dpi = 144, width = 8, height = 8, units = "in" )



# Publish to Twitter
library(rtweet)

## Create Twitter token
yield_curve_token <- rtweet::create_token(
  app = "Will_of_D",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

## Post the tweet to Twitter
rtweet::post_tweet(
  status = status_details,
  media = pic_file,
  token = yield_curve_token
)

on.exit(dbDisconnect(con))
