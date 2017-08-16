library(ggplot2)
library(grid)
library(gridExtra)

data <- read.csv('/Users/philipp/git_repos/projects/PDFLinkExtractor/ICSE.csv', sep = ";")


data <- data[data$Suspicious != "true",]
data <- data[data$DOI != "true",]

df <- data.frame("Ed"=integer(),
                 "Status"=character(),
                 "Frac"=double(),
                 stringsAsFactors=FALSE) 
eds <- unique(data$Ed)
for(ed in eds) {
  codes <- unique(data[data$Ed == ed,]$Code)
  all <- nrow(data[data$Ed == ed,])
  c200 <- nrow(data[data$Ed == ed & data$Code == 200,])
  n200 <- nrow(data[data$Ed == ed & data$Code != 200,])
  df[nrow(df) + 1, ] <- list(ed, "OK", (c200/all))
  df[nrow(df) + 1, ] <- list(ed, "Not OK", (n200/all))
  # for(code in codes) {
  #   this <- nrow(data[data$Ed == ed & data$Code == code,])
  #   df[nrow(df) + 1, ] <- list(ed, code, (this/all))
  # }
}

df$Status <- factor(df$Status)
df$Ed <- factor(df$Ed)

g <- ggplot(df, aes(x = Ed, y = Frac))
p <- g + geom_bar(aes(fill = Status), stat = "identity")
print(p)

data <- data[data$Code != 200,]

data$Code <- factor(data$Code)
data$Ed <- factor(data$Ed)



g <- ggplot(data, aes(Ed))
p <- g + geom_bar(aes(fill = Code))
print(p)