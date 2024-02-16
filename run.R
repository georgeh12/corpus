# working in corpus project
getwd()

install.packages(c('ggplot2', 'shiny', 'koRpus'))
library(koRpus)
install.koRpus.lang("en")
library(shiny)

runApp()


# install.packages("plumber")
# library(plumber)
# # 'plumber.R' is the location of the file shown above
# pr("plumber.R") %>%
#   pr_run(port=80)

mysecret <- readLines("secret.txt")
mytoken <- readLines("token.txt")
install.packages('rsconnect')
library(rsconnect)
rsconnect::setAccountInfo(name='readability',
                          token=mytoken,
                          secret=mysecret)
rsconnect::deployApp('./')
