library(ggplot2)
library(grid)
library(gridExtra)

data <- read.csv('/Users/philipp/git_repos/projects/PDFLinkExtractor/ICSE_cleaned.csv', sep = ";")
data <- data[data$Code != 666,]


data$DOIStat = (data$DOI == "true")
data$DOIStat = factor(data$DOIStat)
data$RefStat = (data$Ref == "true")
data$RefStat = factor(data$RefStat)
data$Code <- factor(data$Code)
data$Ed <- factor(data$Ed)


g <- ggplot(data, aes(x = Ed))
p <- g + geom_bar(aes(fill = DOIStat))
print(p)
g <- ggplot(data, aes(x = Ed))
p <- g + geom_bar(aes(fill = RefStat))
print(p)

# data <- data[data$Suspicious != "true",]
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

df <- data.frame("Ed"=integer(),
                 "Code"=character(),
                 "Frac"=double(),
                 stringsAsFactors=FALSE) 
eds <- unique(data$Ed)
for(ed in eds) {
  codes <- unique(data[data$Ed == ed,]$Code)
  all <- nrow(data[data$Ed == ed,])
  for(code in codes) {
     this <- nrow(data[data$Ed == ed & data$Code == code,])
     df[nrow(df) + 1, ] <- list(ed, code, (this/all))
  }
}
df$Code <- factor(df$Code)
df$Ed <- factor(df$Ed)

g <- ggplot(df, aes(x = Ed, y = Frac))
p <- g + geom_bar(aes(fill = Code), stat = "identity")
print(p)