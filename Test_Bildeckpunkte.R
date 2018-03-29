# speicherort
pathfile = "//132.187.156.211/Lea/Freeviewing_EEG_ET/Daten/"
#pathfile = "Y:\Freeviewing_EEG_ET\Daten\"


# beispieldaten -> testkreuze
list.ex <- dir(path = pathfile, pattern ="Events.txt", full.names = TRUE)
#list.ex.2 <- list.ex[4:5]

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
    fixations <- as.data.frame(fixations)
    saccades <- as.data.frame(saccades)
    blinks <- as.data.frame(blinks)
    messages <- as.data.frame(messages)
    
    names(fixations) <- header_fix
    names(saccades) <- header_sac
    names(blinks) <- header_blnk
    names(messages) <- header_msg
    # if exists("header_trig") {
    #   triggers <- as.data.frame(triggers)
    #   names(triggers) <- header_trig
    # }
    
    outputlist <- list(fixations, saccades, blinks, messages, triggers)  # combine all data in a list for the outpu
    
    close(con)
    #View(header) 
    return(outputlist)  
    
    
  
    ###### save files
    newfilename <- gsub(" Events.txt", "",filepath)   # remove Samples.txt ( but save in same path? otherwise: gsub( ".txt", "",strsplit(list.txt[1], "/")[[1]][6]))
    write.csv(fixations, file=paste0(newfilename, "_fixs.csv"))  # save fixations
    write.csv(saccades, file=paste0(newfilename, "_sacs.csv"))  # save saccades 
    write.csv(blinks, file=paste0(newfilename, "_blnk.csv"))  # save fixations
    write.csv(messages, file=paste0(newfilename, "_msg.csv"))  # save saccades 
    write.csv(triggers, file=paste0(newfilename, "_trg.csv"))  # save fixations
}

ex.1 <- processEvents(list.ex[1]) 
#ex.2 <- processEvents(list.ex.2[2])

## entweder: Daten neu einlesen aus der fix.csv Datei oder ex.1 <- ex.1[[1]] (nur der erste Teil der Liste)
ex.1f <- ex.1[[1]] # 1 = fixations
#ex.2 <- ex.2[[1]]


###
par(mfrow = c(1,2)) #create 1x2 plotting matrix

#plot 1
plot(x = ex.1b$`Location X`,
     y = ex.1b$`Location Y`,
     type = "p",
     main = "Test.1",
     col = "blue",
     pch = 16,
     cex = 1)

#plot 2
plot(x = ex.2$`Location X`,
     y = ex.2$`Location Y`,
     type = "p",
     main = "Test.2",
     col = "red",
     pch = 16,
     cex = 1,#)
     add=TRUE)
