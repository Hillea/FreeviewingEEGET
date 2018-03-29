# speicherort
pathfile = "//132.187.156.211/Lea/Freeviewing_EEG_ET/Daten/"

# liste mit .txt dateien
list.txt <- dir(path = pathfile, pattern ="Samples.txt", full.names=TRUE)


# wähle erste .txt datei
#sample1 <- read.table(list.txt[1], header = TRUE, sep = "\t")



   ##### INFO #######
    # Funktion um die Datei Zeile für Zeile einzulesen (um die ersten 41 Zeilen separat zu speichern, bzw. evtl die messages auch)
    processFile = function(filepath) {
      # initialize data frames
      header <- character()
      #messages <- character()
      #dataET <- character()
      con = file(filepath, "r")
      while ( TRUE ) {
        line = readLines(con, n = 1)
        if ( length(line) == 0 ) {
          break
        }
        #print(line)
        if (regexpr("#", line)[1]==1){    # if the first character in the row is #
          #print(line)
          is.character(line)
          header <- rbind(header, line)   # add new row underneath last one
        } #else if (length(line) < 100) {  # if the row is shorter than ??? 100 characters ???
          #messages <- rbind(messages, line)
       # } else {
        #  dataET <- rbind(dataET, line)
        #}
      }
      
      #outputlist <- list(header, messages, dataET)  # combine all data in a list for the outpu
      close(con)
      #View(header) 
      return(header)
    }
    
for (fl in list.txt){
  
    header <- processFile(fl)
    
    ###### DATEN #######
    # skippe die ersten 41 Zeilen und lese den Rest ein, dabei werden fehlende Zellen mit NAs gefüllt
    sample2 <- read.delim(fl, header = TRUE, sep = "\t", fill=TRUE, row.names = NULL, skip=41)
    
    ###### Preprocessing Data #######
    
    
    
    
    
    
    ###### save files
    newfilename <- gsub(" Samples.txt", "",fl)   # remove Samples.txt ( but save in same path? otherwise: gsub( ".txt", "",strsplit(list.txt[1], "/")[[1]][6]))
    write.csv(header, file=paste0(newfilename, "_info.csv"))  # save header
    write.csv(sample2, file=paste0(newfilename, "_data.csv"))  # save data 
    
}

###
#duplicate column
sample2.new <- cbind(sample2, "L.Raw.X..px.new"=rep(sample2$L.Raw.X..px.))

#store in new df
mydf <- sample2.new[,c("L.Raw.X..px.","L.Raw.X..px.new")]

#finde alle Zeilen mit #
regexpr("#",mydf[,1])==1
#
mydf[,1] <- sub("#", mydf[,1], replacement = NA)
mydf[regexpr("#", mydf[,2])!=1,2] <- NA
head(mydf)

#as.numeric/as.character
mydf[,1] <- as.numeric(mydf[,1])
mydf[,2] <- as.character(mydf[,2])

#verbinde sample 2 mit neuen spalten
sample2.new <- cbind(mydf,sample2[c(1:3, 5:46)])

#change column names
names(sample2.new)[names(sample2.new)=="L.Raw.X..px."] <- "L.Raw.X..px.n"  # number
names(sample2.new)[names(sample2.new)=="L.Raw.X..px.new"] <- "L.Raw.X..px.c"  # character (marker etc)
head(sample2.new,20)

#plot L.Raw.X., L.Raw.Y
ymax <- max(sample2.new[,6], na.rm = TRUE)
xmax <- max(sample2.new[,1], na.rm = TRUE)

###
#
A <- c(-960, -540)
B <- c(960, -540)
C <- c(960, 540)
D <- c(-960, 540)

ggplot(sample2.new, aes(x = L.Raw.X..px.n, y = L.Raw.Y..px.)) +
  geom_point() +
  xlim(600, 700) + ylim(500, 600)

#multiple plot
par(mfrow = c(1,2)) #create 1x2 plotting matrix

#plot 1
plot(x = sample2.new$L.Raw.X..px.n,
     y = sample2.new$L.Raw.Y..px.,
     type = "p",
     main = "Left Eye",
     xlab = "L.Raw.X",
     ylab = "L.Raw.Y",
     xlim = c(635,665), #c(-1160, 1160),
     ylim = c(537,555),# c(-640, 640),
     col = "blue",
     pch = 16,
     cex = 1)

# add horizontal line from A to B
segments(x0 = -960,
         y0 = -540,
         x1 = 960,
         y1 = -540,
         col = gray(0, .5))

# add horizotal line from D to C
segments(x0 = -960,
         y0 = 540,
         x1 = 960,
         y1 = 540,
         col = gray(0, .5))

#add vertical line from A to D
segments(x0 = -960,
         y0 = -540,
         x1 = -960,
         y1 = 540,
         col = gray(0, .5))

#add vertical line from B to C
segments(x0 = 960,
         y0 = -540,
         x1 = 960,
         y1 = 540,
         col = gray(0, .5))

#plot 2
plot(x = sample2.new$R.Raw.X..px.,
     y = sample2.new$R.Raw.Y..px.,
     type = "p",
     main = "Right Eye",
     xlab = "R.Raw.X",
     ylab = "R.Raw.Y",
     xlim = c(-1160, 1160),
     ylim = c(-640, 640),
     col = "blue",
     pch = 16,
     cex = 1)

# add horizontal line from A to B
segments(x0 = -960,
         y0 = -540,
         x1 = 960,
         y1 = -540,
         col = gray(0, .5))

# add horizotal line from D to C
segments(x0 = -960,
         y0 = 540,
         x1 = 960,
         y1 = 540,
         col = gray(0, .5))

#add vertical line from A to D
segments(x0 = -960,
         y0 = -540,
         x1 = -960,
         y1 = 540,
         col = gray(0, .5))

#add vertical line from B to C
segments(x0 = 960,
         y0 = -540,
         x1 = 960,
         y1 = 540,
         col = gray(0, .5))


###### Events
event.txt <- dir(path = pathfile, pattern ="Events.txt", full.names=TRUE)

# somehow find the row with "KEYWORD1" (using readLines?) and skip all rows before
#eventfile <- read.delim(event.txt[1], header=FALSE, sep ="\t", fill=TRUE, row.names=NULL, skip = 23)

##### Split file in 5 dataframes (fixations, saccades, messages, triggers, blinks) #######
# Funktion um die Datei Zeile für Zeile einzulesen 
processEvents = function(filepath) {
    
    # initialize data frames
    fixations <- matrix(nrow = 0, ncol= 13) # I don't know the dim's
    saccades <- matrix(nrow = 0, ncol= 17)
    blinks <- matrix(nrow = 0, ncol= 6)
    messages <- matrix(nrow = 0, ncol= 5)
    triggers <- matrix(nrow = 0, ncol= 6)
    
    con = file(filepath, "r")
    while ( TRUE ) {
      line = readLines(con, n = 1)
      if ( length(line) == 0 ) {
        break
      }
      
     #print(line)
      
      # headers
      if (regexpr("Table Header", line)[1]!=-1){    # if row contains "Table Header"
        if (regexpr("Fixations", line)[1]!=-1){
          line = readLines(con, n = 1)
          header_fix <- unlist(strsplit(line, "\t"))
        } else if (regexpr("Saccades", line)[1]!=-1){
          line = readLines(con, n = 1)
          header_sac <- unlist(strsplit(line, "\t"))
        } else if (regexpr("Blinks", line)[1]!=-1){
          line = readLines(con, n = 1)
          header_blnk <- unlist(strsplit(line, "\t"))
        } else if (regexpr("User Events", line)[1]!=-1){
          line = readLines(con, n = 1)
          header_msg <- unlist(strsplit(line, "\t"))
        } else if (regexpr("Trigger Line", line)[1]!=-1){
          line = readLines(con, n = 1)
          header_trig <- unlist(strsplit(line, "\t"))
        }
        
      } else if (regexpr("Fixation", line)[1]!=-1){    # if it is NOT a header
        fixations <- rbind(fixations,  unlist(strsplit(line, "\t")))
      } else if (regexpr("Saccade", line)[1]!=-1){    # if it is NOT a header
        saccades <- rbind(saccades,  unlist(strsplit(line, "\t"))) 
      } else if (regexpr("Blink", line)[1]!=-1){    # if it is NOT a header
        blinks <- rbind(blinks,  unlist(strsplit(line, "\t")))
      } else if (regexpr("UserEvent", line)[1]!=-1){    # if it is NOT a header
        messages <- rbind(messages,  unlist(strsplit(line, "\t")))  
      } else if (regexpr("TriggerLine", line)[1]!=-1){    # if it is NOT a header
        triggers <- rbind(triggers,  unlist(strsplit(line, "\t")))
      }
      
    }
    
    # TRANSFORM TO DF! 
    fixations <- as.data.frame(fixations)
    saccades <- as.data.frame(saccades)
    blinks <- as.data.frame(blinks)
    messages <- as.data.frame(messages)
    triggers <- as.data.frame(triggers)
    
    names(fixations) <- header_fix
    names(saccades) <- header_sac
    names(blinks) <- header_blnk
    names(messages) <- header_msg
    names(triggers) <- header_trig
    
    outputlist <- list(fixations, saccades, blinks, messages, triggers)  # combine all data in a list for the outpu
    
    close(con)
    #View(header) 
    return(outputlist)
}


for (fl in event.txt){
  
  
  events <- processEvents(fl)
  
 
  
 # split output in 5 dataframes
  fixs <- events[[1]]
  sacs <- events[[2]]
  blinks <- events[[3]]
  msgs <- events[[4]]
  trigs <- events[[5]]
  
  
  ###### save files
  newfilename <- gsub(" Events.txt", "",fl)   # remove Samples.txt ( but save in same path? otherwise: gsub( ".txt", "",strsplit(list.txt[1], "/")[[1]][6]))
  write.csv(fixs, file=paste0(newfilename, "_fixs.csv"))  # save fixations
  write.csv(sacs, file=paste0(newfilename, "_sacs.csv"))  # save saccades 
  write.csv(blinks, file=paste0(newfilename, "_blnk.csv"))  # save fixations
  write.csv(msgs, file=paste0(newfilename, "_msg.csv"))  # save saccades 
  write.csv(trigs, file=paste0(newfilename, "_trg.csv"))  # save fixations

}

fixs$`Location X` <- as.numeric(as.character(fixs$`Location X`))
fixs$`Location Y` <- as.numeric(as.character(fixs$`Location Y`))


# plot fixations
ggplot(data=fixs, aes(x=`Location X`, y=`Location Y`)) + 
  geom_point()
