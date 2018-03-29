pathfile = "//132.187.156.211/Lea/ETdata/"

list.test <- dir(path = pathfile, pattern = "Samples.txt", full.names = TRUE)

sample.test <- read.table(list.test[36], header = TRUE, sep = "\t", fill=TRUE)

sample.test2 <- read.table(list.test[37], header = TRUE, sep = "\t", fill=TRUE)

sample.test3 <- read.table(list.test[38], header = TRUE, sep = "\t", fill=TRUE)

sample.test4 <- read.table(list.test[39], header = TRUE, sep = "\t", fill=TRUE)