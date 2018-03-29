###### Events
library(ggplot2)
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
  


fixs$`Location X` <- as.numeric(as.character(fixs$`Location X`))
fixs$`Location Y` <- as.numeric(as.character(fixs$`Location Y`))


# plot fixations
ggplot(data=fixs, aes(x=`Location X`, y=`Location Y`)) + 
  geom_point()
}

# speicherort
#pathfile ="//132.187.156.211/Lea/ETdata/"

#liste mit beiden testdateien
#list.txt <- dir(path = pathfile, pattern ="Events.txt", full.names = TRUE)

#test.1 <- read.table(list.txt[2], header = TRUE, sep = "\t")