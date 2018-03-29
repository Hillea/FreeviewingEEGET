pathfile ="//132.187.156.211/Lea/ETdata/"

#liste mit beiden testdateien
list.test <- dir(path = pathfile, pattern ="fixs.csv", full.names = TRUE)

#einlesen
table.test.1 <- read.csv(list.test[1])
table.test.2 <- read.csv(list.test[2])
table.test.3 <- read.csv(list.test[3])

ggplot(data=table.test.1, aes(x=Location.X, y=Location.Y)) + 
  geom_point()

ggplot(data=table.test.2, aes(x=Location.X, y=Location.Y)) + 
  geom_point()

ggplot(data=table.test.3, aes(x=Location.X, y=Location.Y)) + 
  geom_point()

###
par(mfrow = c(1,2)) #create 1x2 plotting matrix

#plot 1
#plot(x = table.test.1$Location.X,
     #y = table.test.1$Location.Y,
     #type = "p",
     #main = "Test.1",
     #col = "blue",
     #pch = 16,
     #cex = 1)

#plot 2
plot(x = table.test.2$Location.X,
     y = table.test.2$Location.Y,
     type = "p",
     main = "Test.2",
     col = "blue",
     pch = 16,
     cex = 1)

#plot 3
plot(x = table.test.3$Location.X,
     y = table.test.3$Location.Y,
     type = "p",
     main = "Test.3",
     col = "blue",
     pch = 16,
     cex = 1)# add=TRUE)
