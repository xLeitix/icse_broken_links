library(ggplot2)
library(grid)
library(gridExtra)

data <- read.csv('/Users/philipp/git_repos/projects/icse_broken_links/ICSE.csv', sep = ";")
#data <- data[data$Code != 666,]

# data <- data[data$Paper != "p358-xue.pdf",]

data$DOIStat = (data$DOI == "true")
data$DOIStat = factor(data$DOIStat)
data$RefStat = (data$Ref == "true")
data$RefStat = factor(data$RefStat)
data$Code <- factor(data$Code)
data$Ed <- factor(data$Ed)


g <- ggplot(data, aes(x = Ed))
p <- g + geom_bar(aes(fill = DOIStat))
print(p)

non2017 <- data[data$Ed != "2017",]
g <- ggplot(non2017, aes(x = Ed))
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

broken <- data[data$Code != 200,]

df <- data.frame("Ed"=integer(),
                 "Code"=character(),
                 "Frac"=double(),
                 stringsAsFactors=FALSE) 
eds <- unique(broken$Ed)
for(ed in eds) {
  codes <- unique(broken[broken$Ed == ed,]$Code)
  all <- nrow(broken[broken$Ed == ed,])
  for(code in codes) {
     this <- nrow(broken[broken$Ed == ed & broken$Code == code,])
     df[nrow(df) + 1, ] <- list(ed, code, (this/all))
  }
}
df$Code <- factor(df$Code)
df$Ed <- factor(df$Ed)

g <- ggplot(df, aes(x = Ed, y = Frac))
p <- g + geom_bar(aes(fill = Code), stat = "identity")
print(p)

df <- data.frame("Status"=character(),
                 "Inst"=character(),
                 "Frac"=double(),
                 stringsAsFactors=FALSE) 
academic <- data[data$Type == "academic",]
nacademic <- nrow(academic)
academicLive <- nrow(academic[academic$Live == "true",])
df[nrow(df) + 1, ] <- list("OK", "Institutional", (academicLive/nacademic))
df[nrow(df) + 1, ] <- list("Not OK", "Institutional", (1-(academicLive)/nacademic))

other <- data[data$Type != "academic",]
nother <- nrow(other)
otherLive <- nrow(other[other$Live == "true",])
df[nrow(df) + 1, ] <- list("OK", "Other", (otherLive/nother))
df[nrow(df) + 1, ] <- list("Not OK", "Other", (1-(otherLive)/nother))

df$Status <- factor(df$Status)
df$Inst <- factor(df$Inst)

g <- ggplot(df, aes(x = Inst, y = Frac))
p <- g + geom_bar(aes(fill = Status), stat = "identity")
print(p)