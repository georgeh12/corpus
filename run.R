# working in corpus project
getwd()

install.packages(c('ggplot2', 'shiny', 'koRpus'))
library(koRpus)
install.koRpus.lang("en")
library(shiny)

runApp()


install.packages("plumber")
library(plumber)
# 'plumber.R' is the location of the file shown above
pr("plumber.R") %>%
  pr_run(port=80)

install.packages('rsconnect')
library(rsconnect)
rsconnect::setAccountInfo(name='readability',
                          token='6A512DAA0FD5FC0399E04DA4BA38DB5D',
                          secret='nmv0B+Zsas+JoRazNaB95yR1vMUFYS7dnHENpmlM')
rsconnect::deployApp('./')
