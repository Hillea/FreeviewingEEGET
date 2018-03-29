# get the fixations between certain messages (i.e. stimuli or crosses)

pathfile ="//132.187.156.211/Lea/ETdata/"
list.fix <- dir(path = pathfile, pattern ="fixs.csv", full.names = TRUE) # flexible? both fixs and msgs


fixs2 <- read.csv(list.fix[3], sep=",")
#msgs <- read.csv(list.fix[3], sep=",")
msgs <- messages

fixs$Start <- as.numeric(as.character(fixs$Start))
fixs$`Location X` <- as.numeric(as.character(fixs$`Location X`))
fixs$`Location Y` <- as.numeric(as.character(fixs$`Location Y`))


triggernr <- 35
ind_trig <- regexpr(as.character(triggernr), msgs$Description) > 0

trig_onset_times <- as.numeric(as.character(msgs[ind_trig, "Start"])) 

# find the closest onset times in the ET data with a trick (absolute min of diff)
min_diff_times <- matrix(nrow=length(trig_onset_times), ncol=2)

for (trigs in 1:length(trig_onset_times)) {
  diff_times <- as.numeric(as.character(fixs$Start)) - trig_onset_times[trigs] # now the closest value is close to 0, either slightly bigger or smaller
  tmp <- which(abs(diff_times) == min(abs(diff_times))) # now it is definitely > 0, so we can take the minimum
  print(tmp)
  min_diff_times[trigs,1:2] <- tmp
  # should give two values (one for each eye)
}

# left eye
fix1 <- fixs[min_diff_times[1,1]:(min_diff_times[2,1]-1),]
fix2 <- fixs[min_diff_times[2,1]:(min_diff_times[3,1]-1),]
fix3 <- fixs[min_diff_times[3,1]:(min_diff_times[4,1]-1),]
fix4 <- fixs[min_diff_times[4,1]:(min_diff_times[5,1]-1),]
fix5 <- fixs[min_diff_times[5,1]:(min_diff_times[5,1]+3),]

allfix <- rbind(fix1,fix2,fix3,fix4,fix5)


# coordinates crosses
c1 <- c(0,0) + c(970,600)
c2 <- c(-600, 450) + c(970,600)
c3 <- c(600, -450) + c(970,600)
c4 <- c(600, 450) + c(970,600)
c5 <- c(-600, -450) + c(970,600)


# plot fixs after crosses
ggplot(data=allfix, aes(x=`Location X`, y=`Location Y`)) +
  geom_point(color="red") +
  annotate("text", x = c1[1], y = c1[2], label = "X", color="blue") +
  annotate("text", x = c2[1], y = c2[2], label = "X", color="blue") +
  annotate("text", x = c3[1], y = c3[2], label = "X", color="blue") +
  annotate("text", x = c4[1], y = c4[2], label = "X", color="blue") +
  annotate("text", x = c5[1], y = c5[2], label = "X", color="blue")
