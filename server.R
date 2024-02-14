library(shiny)
library(koRpus)
library(koRpus.lang.en)
library(textreuse)

shinyServer(function(input, output){

	tagged.text <- reactive(koRpus:::tokenize(input$text, format="obj", lang="en"))
	hyphenated.text <- reactive({
		# set the next line to activate caching, if this application is run on a shiny server
		#set.kRp.env(hyph.cache.file=file.path("/var","shiny-server","cache","koRpus",paste("hyph.cache.",input$lang,".rdata", sep="")))
		hyphen(tagged.text(), quiet=TRUE)
	})
    
  output$word.list <- renderTable({
    x <- input$text
    x <- tolower(x)
    words <- unlist (strsplit (x, split = "[[:space:]]+|[[:punct:]]+"))
    Word <- words[words !=""]
    Word.freq <- as.data.frame(table (Word))
    Word.sorted <- Word.freq[order(Word.freq$Freq, decreasing = TRUE), ]
    return(Word.sorted)
  })
    
	output$letter.plot <- renderPlot(plot(tagged.text(), what="letters"))
	output$desc <- renderTable({
		basic.desc.data <- as.data.frame(describe(tagged.text())[c("all.chars","normalized.space","chars.no.space", "letters.only","lines",
			"punct","digits","words","sentences","avg.sentc.length","avg.word.length")])
		syll.desc.data <- as.data.frame(describe(hyphenated.text())[c("num.syll", "avg.syll.word")])
		colnames(basic.desc.data) <- c("All characters","Normalized space","Characters (no space)", "Characters (letters only)","Lines",
			"Punctuation","Digits","Words","Sentences","Avg. sentence length","Avg. word length")
		colnames(syll.desc.data) <- c("Syllables", "Avg. syllable per word")
		desc.data <- cbind(basic.desc.data, syll.desc.data)
		rownames(desc.data) <- c("Value")
		t(desc.data)
	})
	output$desc.lttr.disrib <- renderTable({
		t(describe(tagged.text())[["lttr.distrib"]])
	})
	output$syll.disrib <- renderTable({
		t(describe(hyphenated.text())[["syll.distrib"]])
	})

	LD.results <- reactive(lex.div(tagged.text(), segment=input$LD.segment, factor.size=input$LD.factor, min.tokens=input$LD.minTokens,
			rand.sample=input$LD.random, window=input$LD.window, case.sens=input$LD.caseSens, detailed=FALSE, char=c(), quiet=TRUE))
	output$lexdiv.sum <- renderTable({
		summary(LD.results())
	})
	output$lexdiv.res <- renderPrint({
		LD.results()
	})

	RD.results <- reactive(readability(tagged.text(), hyphen=hyphenated.text(), index=input$RD.indices, quiet=TRUE))
	output$readability.sum <- renderTable({
		summary(RD.results())
	})
	output$readability.score <- renderText({
	  try({
  	  # ChatGPT Desert Island
  	  TextCompare1 = "
        Pros:
        1. Tranquility: Living on a desert island can offer unparalleled peace and solitude, providing a break from the hustle and bustle of modern life.
        2. Connection with Nature: A desert island allows for a deep connection with nature, with the opportunity to appreciate and live in harmony with the environment.
        
        Cons:
        1. Isolation: The lack of human interaction and limited access to amenities can lead to feelings of isolation and loneliness.
        2. Survival Challenges: Obtaining basic necessities such as food, water, and shelter can be challenging, requiring resourcefulness and adaptation to the harsh conditions of the island.
      "
  	  # ChatGPT Social Media
  	  TextCompare2 = "
        Pros of Social Media:
        Connectivity: Enables instant communication and connection with friends, family, and a global network.
        Information Sharing: Facilitates the rapid dissemination of news, trends, and information.
    	  
        Cons of Social Media:
        Privacy Concerns: Raises issues regarding the protection of personal information and privacy.
        Misinformation: Provides a platform for the spread of false information and rumors.
  	  "
  	  similarity1 <- jaccard_similarity(textreuse::tokenize_words(TextCompare1), textreuse::tokenize_words(input$text))
  	  similarity2 <- jaccard_similarity(textreuse::tokenize_words(TextCompare2), textreuse::tokenize_words(input$text))
  	  
  	  readability.test <- readability(tagged.text(), hyphen=hyphenated.text(), index=c("ARI","SMOG","Linsear.Write"), quiet=TRUE)
  	  numUniqueWords <- {
  	    text <- tolower(input$text)
        words <- unlist (strsplit (text, split = "[[:space:]]+|[[:punct:]]+"))
        words <- words[words !=""]
        uniqueWords = table(words)
        length(uniqueWords)
  	  }
  	  
	    #ChatGPT has 35 unique words in the answer minus the headers
	    if(numUniqueWords >= 35 &
	       # ChatGPT answer has a Linsear-Write grade of 3.6
	       readability.test@Linsear.Write$grade > 3.6 &
	       readability.test@ARI$grade > 6 &
	       readability.test@SMOG$grade > 6 &
	       similarity1 < .5 &
	       similarity2 < .5){
	      return(toupper('win'))
  	  }
	  })
	  return(toupper('pass'))
	})
	output$similarity.list <- renderTable({
	  # ChatGPT Desert Island
	  TextCompare1 = "
      Pros:
      1. Tranquility: Living on a desert island can offer unparalleled peace and solitude, providing a break from the hustle and bustle of modern life.
      2. Connection with Nature: A desert island allows for a deep connection with nature, with the opportunity to appreciate and live in harmony with the environment.
      
      Cons:
      1. Isolation: The lack of human interaction and limited access to amenities can lead to feelings of isolation and loneliness.
      2. Survival Challenges: Obtaining basic necessities such as food, water, and shelter can be challenging, requiring resourcefulness and adaptation to the harsh conditions of the island.
    "
	  # ChatGPT Social Media
	  TextCompare2 = "
      Pros of Social Media:
      Connectivity: Enables instant communication and connection with friends, family, and a global network.
      Information Sharing: Facilitates the rapid dissemination of news, trends, and information.
  	  
      Cons of Social Media:
      Privacy Concerns: Raises issues regarding the protection of personal information and privacy.
      Misinformation: Provides a platform for the spread of false information and rumors.
	  "
	  similarity1 <- jaccard_similarity(textreuse::tokenize_words(TextCompare1), textreuse::tokenize_words(input$text))
	  similarity2 <- jaccard_similarity(textreuse::tokenize_words(TextCompare2), textreuse::tokenize_words(input$text))

	  ChatGPT.text <- c(HTML(TextCompare1), HTML(TextCompare2))
	  Jaccard.similarity <- c(similarity1,similarity2)
	  data.frame(ChatGPT.text,Jaccard.similarity)
	})
	output$readability.res <- renderPrint({
		RD.results()
	})

})
