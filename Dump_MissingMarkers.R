orig_start_idx <- idx_start_pic
orig_end_idx <- idx_end_pic

too_small_start <- which(diff(idx_start_pic) < 3000)

while (too_small_start) {
  # the one with the idx - 1 is correct, so delete idx maker?!
  idx_start_pic <- idx_start_pic[too_small_start[1]]
}

too_small_end <- which(diff(idx_end_pic) < 3000)

## load log file to compare # change flet!
# VPnr <- flet %>% str_split("/") %>% map(~.x[9]) %>% unlist() %>% str_split("_") %>% map(~.x[1]) %>% unlist()
# logFilePath <- dir(path = "//132.187.156.211/Lea/Freeviewing_EEG_ET/Daten/Logs/", pattern = glob2rx(paste0("*", VPnr, "*.csv")), full.names=TRUE)
# logfile <- read_csv(logFilePath)

### Missing markers?? ####
# mark_idx = 1
# while (mark_idx <= length(idx_start_pic)) { # idx start should be at least as long as mark_idx, even if it is cont. prolonged?!
#   
#   # check whether diff end-start is unreasonable (not between 2000 and 3000 samples)
#   if ((idx_end_pic[mark_idx] - idx_start_pic[mark_idx]) > 3000 || (idx_end_pic[mark_idx] - idx_start_pic[mark_idx]) < 2000){
#     
#     # check if start marker is problem, not enough space between markers
#     if mark_idx==1{
#       if idx_start_pic[mark_idx+1] - idx_start_pic[mark_idx] < 3000 {
#         next_start_marker <- idx_end_pic[mark_idx] - idx_start_pic[mark_idx+1] # compare 
#         same_start_marker <- idx_end_pic[mark_idx] - idx_start_pic[mark_idx]
#         
#         ifelse(abs(next_start_marker-2525) > abs(same_start_marker-2525),
#                 real_idx <- mark_idx,
#                 real_idx <- mark_idx+1)
#          
#       }
#       if idx_end_pic[mark_idx+1] - idx_end_pic[mark_idx] < 3000 {
#         next_start_marker <- idx_end_pic[mark_idx] - idx_start_pic[mark_idx+1] # compare 
#         same_start_marker <- idx_end_pic[mark_idx] - idx_start_pic[mark_idx]
#         
#         ifelse(abs(next_start_marker-2525) > abs(same_start_marker-2525),
#                 real_idx <- mark_idx,
#                 real_idx <- mark_idx+1)
#          
#       }
#       
#     } else {
#       if idx_start_pic[mark_idx] - idx_start_pic[mark_idx-1] < 3000 {
#         next_start_marker <- idx_end_pic[mark_idx] - idx_start_pic[mark_idx-1] # compare 
#         same_start_marker <- idx_end_pic[mark_idx] - idx_start_pic[mark_idx]
#         
#         ifelse(abs(next_start_marker-2525) > abs(same_start_marker-2525),
#                 real_idx <- mark_idx,
#                 real_idx <- mark_idx+1)
#          
#       }
#       if idx_end_pic[mark_idx] - idx_end_pic[mark_idx-1] < 3000 {
#         next_start_marker <- idx_end_pic[mark_idx] - idx_start_pic[mark_idx+1] # compare 
#         same_start_marker <- idx_end_pic[mark_idx] - idx_start_pic[mark_idx]
#         
#         ifelse(abs(next_start_marker-2525) > abs(same_start_marker-2525),
#                 real_idx <- mark_idx,
#                 real_idx <- mark_idx+1)
#          
#       }
#     }
#   }
# }
# ##### 0. non-overlapping stimuli, at least 3000 samples between start/end markers
# 
#   too_small_end <- which(diff(idx_end_pic)<3000)
#  # too_big_start <- which(diff(idx_start_pic)>4000) # after the practice session = longer period
# 
# ##### 1. Same amount of (start and end) markers? 
#     
# # no negative diffs and same amount
# while (length(idx_start_pic) > length(idx_end_pic)) {  # more start markers than end markers
#   idx_miss_marker <- which(idx_end_pic - idx_start_pic > 2550)[1]   # first strange mmarker
#   
#   ## end marker missing (diff(e) > 4000) or start marker too much (diff(s) < 3000)
#   too_small_start <- which(diff(idx_start_pic) < 3000)
#   too_big_end <- which(diff(idx_end_pic) > 4000)
#   
#   ## Difference/distance both start markers and end marker
#   
#   # if this is 9, it would be either marker 8 or 9 correct, it should be the one that is closest to other marker (end) to 10.1sec, 2525 samples
#   big_diff <- idx_end_pic[idx_miss_marker-1]-idx_start_pic[idx_miss_marker] # compare 
#   small_diff <- idx_end_pic[idx_miss_marker-1]-idx_start_pic[idx_miss_marker-1]
#   
# 
#   # Do we need to add end marker or delete start marker?
#   
#   
#   if(abs(big_diff-2525) > abs(small_diff-2525)){
#     # small_diff is better, i.e. it should be smaller idx_start_pic [idx_miss_marker-1]
#     real_idx <- idx_miss_marker-1#idx_start_pic[idx_miss_marker-1]
#     wrong_idx <- idx_miss_marker
#   } else { # big_diff better
#       real_idx <- idx_miss_marker
#       wrong_idx <- idx_miss_marker-1
#   }
#   
# 
#   # add approx index for missing end marker (start marker + 2525 samples)
#   idx_end_pic <- c(idx_end_pic[1:real_idx-1], idx_start_pic[real_idx] + 2525, idx_end_pic[real_idx:length(idx_end_pic)])
#   
# } 
# 
# while (length(idx_start_pic) < length(idx_end_pic)) {  # more end markers
#   idx_miss_marker <- which(idx_end_pic - idx_start_pic < 2000)[1]   # if one marker is missing
#   # if this is 9, it would be either marker 8 or 9 correct, it should be the one that is closest to other marker (end) to 10.1sec, 2525 samples
#   big_diff <- idx_end_pic[idx_miss_marker] - idx_start_pic[idx_miss_marker-1] # compare 
#   small_diff <- idx_end_pic[idx_miss_marker-1] - idx_start_pic[idx_miss_marker-1]
#   
#   if(abs(big_diff-2525) > abs(small_diff-2525)){
#     # small_diff is better, i.e. it should be smaller idx_start_pic [idx_miss_marker-1]
#     real_idx <- idx_miss_marker-1#idx_start_pic[idx_miss_marker-1]
#   } else { # big_diff better
#       real_idx <- idx_miss_marker
#     }
#   
#   # add approx index for missing end marker (start marker + 2525 samples)
#   idx_start_pic <- c(idx_end_pic[1:real_idx-1], idx_start_pic[real_idx] + 2525, idx_end_pic[real_idx:length(idx_end_pic)])      
#   
# }