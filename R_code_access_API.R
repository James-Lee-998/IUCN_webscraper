#Packages
suppressMessages(library(utils))
suppressMessages(library(rredlist))
suppressMessages(library(tidyverse))
suppressMessages(library(rlist))
suppressMessages(library(reshape2))
suppressMessages(library(ggplot2))
suppressMessages(library(Rmisc))
suppressMessage(library(dplyr))
suppressMessage(library(plotly))
####################################API and requests############################################
################################################################################################

#Obtain IUCN API key 
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

Endangered_list <- all_df %>% 
  filter(category == c('CR','EN', 'VU', 'LR')) %>% 
  mutate(iucn_pull = map(scientific_name, rl_habitats, key = apikey))

api_clean <- Endangered_list %>% 
  mutate(habitat = map(iucn_pull, pluck, "result", "habitat")) %>% 
  select(scientific_name, habitat) %>%
  mutate(BOOLEAN = map(habitat, `%in%`, x = 'Forest - Subtropical/Tropical Moist Montane')) %>%
  filter(BOOLEAN == 'TRUE') %>%
  select(scientific_name) %>%
  mutate(iucn_pull_2 = map(scientific_name, rl_search, key = apikey)) %>%
  mutate(elevation_lower = as.numeric(map(iucn_pull_2, pluck, "result", "elevation_lower"))) %>%
  mutate(category = as.character(map(iucn_pull_2, pluck, "result", "category"))) %>% 
  select(scientific_name, elevation_lower, category) %>%
  filter(elevation_lower > 1000)

###################sort list so we only get species with an elevation_lower of 1000m###############
###################################################################################################

write.csv(api_clean, "D:\\ENDANGERED_MALAYSIA_ELEVATION_1000.csv", row.names = FALSE)

model_1 = aov(elevation_lower~category, data = api_clean)

shapiro.test(resid(aov(elevation_lower~category, data = api_clean)))

model_2 = kruskal.test(elevation_lower~category, data = api_clean)

model_2

tgc <- summarySE(api_clean, measurevar="elevation_lower", groupvars="category")

plot_1 = ggplot(api_clean, aes(x = category, y = elevation_lower, fill = category, label = scientific_name)) + 
  geom_jitter(width = 0.1) +
  geom_boxplot() + 
  scale_fill_discrete(labels = c("Critically Endangered", "Endagered", "Vulnerable")) + 
  scale_y_continuous(limits = c(0,3500), expand = c(0,NA)) +
  labs(y = "Lower elevation /m", x = " ", fill = "IUCN category") + 
  theme_bw()

ggplotly(plot_1)