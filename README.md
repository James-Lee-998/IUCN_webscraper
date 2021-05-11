# IUCN_webscraper
An online IUCN webscraper designed for custom outputs to track red listed species. We have three main steps in procuring and realising data which comes from APIs:

(1) API and requests

API or Application Programming interface is a bridge between software applications. The use of APIs constitute requests and calls, which in our case is callable data.
We obtain information from our API by using requests, and call certain features of that request to access specified information. For example, if I wanted to search a webpage
using an API and I only want pictures of cats then my request would come in the form of a recognisiable tag or a TOKEN. TOKENs define specified categorical parameters which narrow the scope of that request. So in our example, say convenienently the webpage sorts all cat pictures under one TOKEN, we only need to find out what this TOKEN is to form a request which obtains only cat pictures.

(2) Sorting request data in to meaningful arrays

Now data needs to be filtered and sorted after a request. Luckily R allows us to sort through dataframes and data structures conditionally. The premise of this is to only obtain what you want. With the IUCN API specifically it is hard to do one single search for items which we want. Each request is specific in the sense that habitats and narrative information cannot be obtained in one single request. This requires recursive searching and sorting until we narrow down dataframes to all the data we wanted in the first place.

(3) Plotting data

Although not shown in the tutorial, now that you have a large dataframe of 'probably' everything you want, you can start doing analysis on them. For example the package 'red' can be used to geographically map index species by range and distribution. (Cardoso, P., 2017. red-an R package to facilitate species red list assessments according to the IUCN criteria. Biodiversity Data Journal, (5).) I will promptly add another section to the code depicting this in the near future.

See also: Caviedes-Solis, I.W., Kim, N. and Leaché, A.D., 2020. Species IUCN threat status level increases with elevation: a phylogenetic approach for Neotropical tree frog conservation. Biodiversity and Conservation, 29(8), pp.2515-2537. 
for another example of the application of IUCN APIs
