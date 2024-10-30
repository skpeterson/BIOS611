library(tidyverse)
library(here)
library(NatParksPalettes)

data <- read_csv('work/source_data/pet_adoption_data.csv')
colnames(data)


data %>% group_by(PetType, Breed) %>% count()

ggplot(data %>% group_by(PetType, Breed) %>% count(), aes(x=PetType,y=n,fill=Breed)) +
  geom_col() +
  theme_classic() + 
  scale_fill_natparks_d(name='Arches')
