#Packages
suppressMessages(library(utils))
suppressMessages(library(rredlist))
suppressMessages(library(tidyverse))
suppressMessages(library(rlist))
suppressMessages(library(reshape2))

####################################API and requests############################################
################################################################################################

#Obtain IUCN API key 
Sys.setenv(IUCN_KEY = 'fcf03dabdd0e2353081b6eac1a965078748e52b345f661492a2aff580d58f3a9')
Sys.getenv("IUCN_KEY") # hides IUCN API key in R environment
apikey <- Sys.getenv("IUCN_KEY") # Obtains API key from environment and sets it to callable variable

#Gorilla test
test = rl_search('Gorilla gorilla', key = apikey) # rl_search is a function which allows us to search at a species by species basis
test # should print a data-frame of Gorrila gorilla with preliminary information

out <- rl_sp_country(country = 'MY', key = apikey) # rl_search by country so all species in that country contained in the API can be obtained
# in this case the search country is malaysia isocode is MY
all_df <- out$result # obtain results only

###################################Sorting request data in to meaningful arrays#################
################################################################################################

# obtain all endangered species quoted isocodes are indicative of endangered or vulnerable categories
all_df = all_df[(all_df$category == 'CR' | all_df$category == 'EN' | all_df$category == 'VU' | all_df$category == 'LR'),]
Endangered_list = as.data.frame(all_df$scientific_name) # primes the species list so that we only see species which are vulnerable
colna = "Species"
colnames(Endangered_list) = colna

df <- Endangered_list %>%  # iterate through endangered species list and obtain their respective habitats
  mutate(iucn_pull = map(Species, rl_habitats, key = apikey))

api_clean <- df %>% # cleans the data so we obtain only the habitats
  mutate(habitat = map(iucn_pull, pluck, "result", "habitat")) %>% 
  select(Species, habitat)

# creates a new logic column in the dataframe, where by true refers to forest - subtropical/tropical montane habitats
api_clean['BOOLEAN'] = list(sapply(api_clean$habitat, `%in%`, x = 'Forest - Subtropical/Tropical Moist Montane'))

# obtains all true values returning all scientific names for montane species
api_clean_true = api_clean[(api_clean[3] == 'TRUE'),]

# search through all species lists once again to obtain narrative information
df_complete = api_clean_true %>%
  mutate(iucn_pull_2 = map(Species, rl_search, key = apikey))

final_df <- df_complete %>% # cleans the data so we obtain only elevation_lower
  mutate(elevation_lower = map(iucn_pull_2, pluck, "result", "elevation_lower")) %>% 
  select(Species, elevation_lower)

#sort list so we only get species with an elevation_lower of 1000m
final_df = final_df[(final_df$elevation_lower == '1000'),]
