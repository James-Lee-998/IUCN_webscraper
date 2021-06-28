#Application Programming Interfaces for optomised species searches

This ReadMe file takes you through the use of R (and Python) as a function of accessing the IUCN Red List (http://apiv3.iucnredlist.org/api/v3/docs) as well as the GBIF API (https://www.gbif.org/developer/summary). The API for IUCN and GBIF both have inbuilt R packages for the use of their APIs. 

IUCN red list - rredlist (https://www.rdocumentation.org/packages/rredlist/versions/0.5.0)

GBIF - RGBIF
(https://docs.ropensci.org/rgbif/articles/rgbif.html)

##Firstly a quick description of APIs:

API or Application Programming interface is a bridge between software applications, allowing for cross-communication between software applications. The use of APIs constitute requests and calls, which in our case is callable data.
We obtain information from our API by using requests, and call certain features of that request to access information. 

![alt text](https://github.com/James-Lee-998/IUCN_webscraper/Images for Readme/API_image.png?raw=true)

We will be talking directly to the API via a programming language: namely R and Python. I chose these two as they are probably the best languages for data sorting and analysis. You may use other languages but they are usually suited for other roles such as Java which is mostly used for the production of software. 

##Rstudio

To start off we must first download R. R is an open-source statistical programming language. It may be downloaded from https://www.r-project.org/. The newest version is R version 4.1.0 (Camp Pontanezen). R is linked with CRAN (Comprehensive R Archive Network) which forms the library of packages for R. 

![alt text](https://github.com/James-Lee-998/IUCN_webscraper/Images for Readme/R_image.png?raw=true)

This image shows the Imperial CRAN mirror. To be honest it doesn't really matter where from the UK you pick your CRAN mirror it all works the same. 

Next you will have to download Rstudio:

https://www.rstudio.com/products/rstudio/download/

Rstudio is an IDE or an Integrated Development Environment. It is a piece of software which helps display your code alongside multiple other facets such as a box to view your current directory or your files and much more. 

Now that you have both downloaded we can start coding. If you are new to R then I suggest you have a look at the R primer on this repository written by Tom Ezard. 

I am assuming you will be using templates of code but also if you just want to have a quick look at the code in Rstudio please feel free to clone this repository. You can do this by using the version control. 

Copy this link: https://github.com/James-Lee-998/IUCN_webscraper.git

If you want to set up a git clone on Rstudio (which means to have the entire repository on your system for easy access) just open a new project on R.

File --> New Project --> Version Control --> Git

And paste the link into the empty tab. 

You can also download it as a zip if you press the green button on github called 'CODE' it will give you an option to download it as a zip file. 

##Installing packages on R

```{r}
install.packages('rredlist') # IUCN red list
library(rredlist) # initate the package from library

install.packages('rgbif') # GBIF 
library(rgbif)
```

To follow examples for both GBIF and IUCN API use on R please refer to the files:

 - IUCN_example.R
 - GBIF_example.R
 




