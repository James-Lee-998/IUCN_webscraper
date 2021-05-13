#Packages
suppressMessages(library(utils))
suppressMessages(library(rredlist))
suppressMessages(library(tidyverse))
suppressMessages(library(rlist))
suppressMessages(library(reshape2))
suppressMessages(library(ggplot2))
suppressMessages(library(Rmisc))

####################################API and requests############################################
################################################################################################

#Obtain IUCN API key 
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

final_df_2 <- df_complete %>% # cleans the data so we obtain only elevation_lower
  mutate(endangered = map(iucn_pull_2, pluck, "result", "category")) %>% 
  select(Species, endangered)

###################sort list so we only get species with an elevation_lower of 1000m###############
###################################################################################################

final_df = cbind(final_df,final_df_2)
final_df = final_df[(!final_df$elevation_lower == 'NA'),]
final_df = final_df[(!final_df$elevation_lower < 1000),]
final_df = final_df %>% select(-3)

final_df['elevation'] = unlist(final_df$elevation_lower)
final_df['category'] = unlist(final_df$endangered)
final_df = final_df %>% select(-elevation_lower & -endangered)

ggplot(final_df, aes(x = Species, y = elevation, color = category)) + geom_point() + 
  theme_bw() + 
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  scale_y_continuous(limits = c(1000,NA), expand = c(1000,NA))

write.csv(final_df, "D:\\ENDANGERED_MALAYSIA_ELEVATION_1000.csv", row.names = FALSE)

x = aov(elevation~category, data = final_df)
summary(x)

tgc <- summarySE(final_df, measurevar="elevation", groupvars="category")

ggplot(final_df, aes(x = category, y = elevation, fill = category)) + geom_boxplot() + 
  geom_jitter(width = 0.1) + 
  scale_fill_discrete(labels = c("Critically Endangered", "Endagered", "Vulnerable")) + 
  scale_y_continuous(limits = c(0,3500), expand = c(0,NA)) +
  labs(y = "Lower elevation /m", x = " ", fill = "IUCN category") + 
  theme_bw()
