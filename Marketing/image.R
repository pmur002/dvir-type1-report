

## Run in ...
## sudo docker run -v $(pwd):/home/work/ -w /home/work --rm -t -i pmur002/dvir-type1 /bin/bash

png("demo-bad.png", res=100, width=200, height=100, bg="transparent")
library(dvir, lib.loc="/opt/R/dvir/version-0.3-0")
grid.latex("\\Huge $x - \\mu$")
dev.off()

detach("package:dvir")
unloadNamespace("dvir")
graphics.off()

png("demo-good.png", res=100, width=200, height=100, bg="transparent")
library(dvir, lib.loc="/opt/R/dvir/version-0.3-1")
preamble <- "
\\documentclass[12pt]{standalone}
\\usepackage{unicode-math}
\\begin{document}
"
grid.latex("\\Huge $x - \\mu$", 
           preamble=preamble, 
           engine=lualatexEngine)
dev.off()




## Run on local machine ...

library(png)
library(grid)

png("bling.png", res=100, width=200, height=100)

img1 <- readPNG("demo-good.png")
img2 <- readPNG("demo-bad.png")

grid.newpage()
grid.raster(img2, x=.48)
grid.rect(gp=gpar(col=NA, fill=rgb(1,1,1,.8)))
grid.raster(img1)

dev.off()
