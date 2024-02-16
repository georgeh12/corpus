library(shiny)
require(httr)

shinyUI(
	pageWithSidebar(
		headerPanel(c("Text Analysis Score: ", p(strong(textOutput("readability.score"))))),
		
		sidebarPanel(
      # limit the maximum amount of text to be analyzed
      includeHTML("./maxlength.html"),
      h4("Text to analyze:"),
      tags$textarea(id="text", rows=30, cols=35, maxlength=10000,autofocus="autofocus",
        onfocus="if(this.value==\"(Paste your text here. Text limit is 10000 characters, but should at least have 100 words.)\")
          this.value=decodeURI(window.location.toString().split('?')[1]);",
        "(Paste your text here. Text limit is 10000 characters, but should at least have 100 words.)"),
			conditionalPanel("input.tab == 'chkLexdiv'",
				h4("Lexical diversity options:"),
				numericInput("LD.segment", "MSTTR segment size:", 100),
				sliderInput("LD.factor", "MTLD/MTLD-MA factor size:", min=0, max=1, value=0.72),
				numericInput("LD.minTokens", "MTLD-MA min. tokens/factor:", 9),
				numericInput("LD.random", "HD-D sample size:", 42),
				numericInput("LD.window", "MATTR moving window:", 100),
				checkboxInput("LD.caseSens", "Case sensitive", FALSE)
			),
			conditionalPanel("input.tab == 'similarity'",
			                 h4("Similarity to ChatGPT answers:")
			),
			conditionalPanel("input.tab == 'chkReadability'",
				h4("Readability options:"),
				checkboxGroupInput("RD.indices", label="Measures to calculate",
					choices=c("ARI"="ARI",
					          "ARI (NRI)"="ARI.NRI",
					          "ARI (simplified)"="ARI.simple",
					          "Bormuth"="Bormuth",
					          "Coleman"="Coleman",
					          "Coleman-Liau"="Coleman.Liau",
					          "Dale-Chall"="Dale.Chall",
					          "Danielson-Bryan"="Danielson.Bryan",
					          "Dickes-Steiwer"="Dickes.Steiwer",
					          "Degrees of Reading Power (DRP)"="DRP",
					          "ELF"="ELF",
					          "Farr-Jenkins-Paterson"="Farr.Jenkins.Paterson",
					          "Farr-Jenkins-Paterson (Powers-Sumner-Kearl)"="Farr.Jenkins.Paterson.PSK",
					          "Flesch"="Flesch",
					          "Flesch (Powers-Sumner-Kearl)"="Flesch.PSK",
					          "Flesch-Kincaid"="Flesch.Kincaid",
					          "FOG"="FOG",
					          "FOG (Powers-Sumner-Kearl)"="FOG.PSK",
					          "FOG (NRI)"="FOG.NRI",
					          "FORCAST"="FORCAST",
					          "FORCAST (reading grade level)"="FORCAST.RGL",
					          "Fucks Stilcharakteristik"="Fucks",
					          "Gutierrez"="Gutierrez",
					          "Harris-Jacobson"="Harris.Jacobson",
					          "Linsear-Write"="Linsear.Write",
					          "LIX"="LIX",
					          "Neue Wiener Sachtextformeln"="nWS",
					          "RIX"="RIX",
					          "SMOG"="SMOG",
					          "SMOG (formula C)"="SMOG.C",
					          "SMOG (simplified)"="SMOG.simple",
					          "Spache"="Spache",
					          "Strain"="Strain",
					          "Traenkle-Bailer"="Traenkle.Bailer",
					          "TRI"="TRI",
					          "Tuldava"="Tuldava",
					          "Wheeler-Smith"="Wheeler.Smith"),
					selected=c("ARI"="ARI",
					          "ARI (NRI)"="ARI.NRI",
					          "ARI (simplified)"="ARI.simple",
					          "Bormuth"="Bormuth",
					          "Coleman"="Coleman",
					          "Coleman-Liau"="Coleman.Liau",
					          "Dale-Chall"="Dale.Chall",
					          "Danielson-Bryan"="Danielson.Bryan",
					          "Dickes-Steiwer"="Dickes.Steiwer",
					          "Degrees of Reading Power (DRP)"="DRP",
					          "ELF"="ELF",
					          "Farr-Jenkins-Paterson"="Farr.Jenkins.Paterson",
					          "Farr-Jenkins-Paterson (Powers-Sumner-Kearl)"="Farr.Jenkins.Paterson.PSK",
					          "Flesch"="Flesch",
					          "Flesch (Powers-Sumner-Kearl)"="Flesch.PSK",
					          "Flesch-Kincaid"="Flesch.Kincaid",
					          "FOG"="FOG",
					          "FOG (Powers-Sumner-Kearl)"="FOG.PSK",
					          "FOG (NRI)"="FOG.NRI",
					          "FORCAST"="FORCAST",
					          "FORCAST (reading grade level)"="FORCAST.RGL",
					          "Fucks Stilcharakteristik"="Fucks",
					          "Gutierrez"="Gutierrez",
					          "Harris-Jacobson"="Harris.Jacobson",
					          "Linsear-Write"="Linsear.Write",
					          "LIX"="LIX",
					          "Neue Wiener Sachtextformeln"="nWS",
					          "RIX"="RIX",
					          "SMOG"="SMOG",
					          "SMOG (formula C)"="SMOG.C",
					          "SMOG (simplified)"="SMOG.simple",
					          "Spache"="Spache",
					          "Strain"="Strain",
					          "Traenkle-Bailer"="Traenkle.Bailer",
					          "TRI"="TRI",
					          "Tuldava"="Tuldava",
					          "Wheeler-Smith"="Wheeler.Smith")
			))
#			submitButton("Update View")
		),


		mainPanel(

			tabsetPanel(
			  tabPanel("Readability",
					h5("Summary"),
					tableOutput("readability.sum"),
					h5("Details"),
					pre(textOutput("readability.res")),
					value="chkReadability"
				),
				tabPanel("Descriptive statistics",
					tableOutput("desc"),
					h5("Word length (letters)"),
					tableOutput("desc.lttr.disrib"),
					h5("Word length (syllables)"),
					tableOutput("syll.disrib"),
					plotOutput("letter.plot")
				),
        tabPanel("Word list",
          h5(verbatimTextOutput("word.list.unique")),
          tableOutput("word.list")
        ),
				tabPanel("Lexical diversity",
					h5("Summary"),
					tableOutput("lexdiv.sum"),
					h5("Details"),
					pre(textOutput("lexdiv.res")),
					value="chkLexdiv"
				),
				tabPanel("Similarity list",
				         tableOutput("similarity.list")
				),


        tabPanel("About",
            strong('Note'),
                p('This web application is developed with',
                a("Shiny.", href="http://www.rstudio.com/shiny/", target="_blank"),
                ''),
            br(),

            strong('List of Packages Used'), br(),
                code('library(shiny)'),br(),
                code('library(koRpus)'),br(),

            br(),

            strong('Code'),
                p('Source code for this application is mostly from',
                a('koRpus: An R packge for text analysis.', href='http://reaktanz.de/?c=hacking&s=koRpus', target="_blank")),

                p('The code for this web application is available at',
                a('GitHub.', href='https://github.com/mizumot/corpus', target="_blank")),

                p('If you want to run this code on your computer (in a local R session), run the code below:',
                br(),
                code('library(shiny)'),br(),
                code('runGitHub("corpus","mizumot")')
                ),

            br(),

            strong('Citation in Publications'),
                p('Mizumoto, A. (2015). Langtest (Version 1.0) [Web application]. Retrieved from http://langtest.jp'),

            br(),

            strong('Article'),
                p('Mizumoto, A., & Plonsky, L. (2015).', a("R as a lingua franca: Advantages of using R for quantitative research in applied linguistics.", href='http://applij.oxfordjournals.org/content/early/2015/06/24/applin.amv025.abstract', target="_blank"), em('Applied Linguistics,'), 'Advance online publication. doi:10.1093/applin/amv025'),

            br(),

            strong('Recommended'),
                p('To learn more about R, I suggest this excellent and free e-book (pdf),',
                a("A Guide to Doing Statistics in Second Language Research Using R,", href="http://cw.routledge.com/textbooks/9780805861853/guide-to-R.asp", target="_blank"),
                    'written by Dr. Jenifer Larson-Hall.'),

                p('Also, if you are a cool Mac user and want to use R with GUI,',
                    a("MacR", href="https://sites.google.com/site/casualmacr/", target="_blank"),
                    'is defenitely the way to go!'),

            br(),

            strong('Author'),
                p('Edited by George Hardigg, PhD Student, University of Pittsburgh ', a("geh71@pitt.edu",href="mailto:geh71@pitt.edu", target="_blank"),br(),
                a("Atsushi MIZUMOTO,", href="http://mizumot.com", target="_blank"),' Ph.D.',br(),
                'Associate Professor of Applied Linguistics',br(),
                'Faculty of Foreign Language Studies /',br(),
                'Graduate School of Foreign Language Education and Research,',br(),
                'Kansai University, Osaka, Japan'),

            br(),

            a(img(src="http://i.creativecommons.org/p/mark/1.0/80x15.png"), target="_blank", href="http://creativecommons.org/publicdomain/mark/1.0/"),

            p(br())

        )

    ))
))