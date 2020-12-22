
TARFILE = ../dvir-type1-deposit-$(shell date +'%Y-%m-%d').tar.gz
Rscript = Rscript

%.xml: %.cml %.bib
	# Protect HTML special chars in R code chunks
	$(Rscript) clean.R $*.cml
	$(Rscript) toc.R $*.xml
	$(Rscript) bib.R $*.xml
	$(Rscript) foot.R $*.xml
	## Replace any -- (that are neither <!-- nor -->) with &#x002D;
	## For XSL processing (.xml -> .Rhtml)
	$(Rscript) -e 'x <- readLines("$*.xml"); writeLines(gsub("([^!])--([^>])", "\\1&#x002D;&#x002D;\\2", x), "$*.xml")'

%.Rhtml : %.xml
	# Transform to .Rhtml
	xsltproc knitr.xsl $*.xml > $*.Rhtml
	## Reverse transform &#002D;&#002D; -> -- (post XSL processing)
	## AND make sure <!--begin.rcode is on its own line
	## For 'knitr' processing (.Rhtml -> .html)
	$(Rscript) -e 'x <- readLines("$*.Rhtml"); writeLines(gsub("&#x002D;&#x002D;", "--", gsub("><!--begin.rcode", ">\n<!--begin.rcode", x)), "$*.Rhtml")'

%.html : %.Rhtml
	# Use knitr to produce HTML
	$(Rscript) knit.R $*.Rhtml
	# Remove wonky LaTeX commands that knitr is inserting in HTML output
	$(Rscript) -e 'x <- readLines("$*.html"); writeLines(gsub("^\\\\let\\\\hlesc\\\\hlstd.+", "", x), "$*.html")'

docker:
	cp ../../dvir_0.3-0.tar.gz .
	cp ../../dvir_0.3-1.tar.gz .
	sudo docker build -t pmur002/dvir-type1 .
	sudo docker run -v $(shell pwd):/home/work/ -w /home/work --rm pmur002/dvir-type1 make dvir-type1.html

web:
	make docker
	cp -r ../dvir-type1-report/* ~/Web/Reports/dvir/type1/

zip:
	make docker
	tar zcvf $(TARFILE) ./*
