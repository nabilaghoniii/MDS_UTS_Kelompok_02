
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


# Get yield curve
library(RCurl)
download <- getURL("https://home.treasury.gov/resource-center/data-chart-center/interest-rates/daily-treasury-rates.csv/all/all?type=daily_treasury_yield_curve&field_tdr_date_value=all&page&_format=csv")
data <- read.csv(text = download)

# Send data to elephant sql
dbWriteTable(conn = con, 
             name = "UpdateTreasury", 
             value = data, 
             append = FALSE, 
             row.names = TRUE, 
             overwrite=TRUE)

on.exit(dbDisconnect(con)) 
