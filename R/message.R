library(twilio)

# load environmental vars
tw_sid <- Sys.getenv("TWILIO_SID")
tw_tok <- Sys.getenv("TWILIO_TOKEN")
tw_phone_number <- Sys.getenv("TWILIO_PHONE_NUMBER")

# configure auth
Sys.setenv(TWILIO_SID   = tw_sid)
Sys.setenv(TWILIO_TOKEN = tw_tok)

# capture numbers which follow the env var convention
# PHONE_NUMBER_{initials}, input as Github secrets
env_vars <- names(Sys.getenv())
num_ids  <- env_vars[grep("PHONE_NUMBER_", env_vars)]
nums     <- unlist(lapply(num_ids, Sys.getenv))
cat(length(nums), "phone numbers found.\n")

# read Keanu factoids
df <- read.csv(here::here("R/facts.csv"))

# counter
i <- read.csv(here::here("csv/counter.csv"))$counter

# randomly sample counter if it's out of range of the data
if(i > nrow(df)){
  i = sample(1:nrow(df), 1)
}

# send message
for(j in seq_along(nums)){
  cat("Preparing to send row number", i, "to phone number", j, "...")
  tw_send_message(from = tw_phone_number, 
                  to   = nums[j],
                  body = df$factoid[i])
  cat(" sent.\n")
}

# increment counter and save
i <- i + 1
write.csv(data.frame(counter = i), here::here("csv/counter.csv"))
