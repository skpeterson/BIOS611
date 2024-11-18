library(tidyverse)
library(here)
library(NatParksPalettes)
library(ggridges)
library(cowplot)

data_all <- read.csv('work/data/working_data/train_adoption_values_to_category_data.csv', sep = ',')

palette <- natparks.pals("Saguaro",n = 2)
adoption_dist <- ggplot(data_all, aes(x=AdoptionSpeed, y=Type, fill=Type)) + 
  geom_density_ridges() +
  scale_fill_manual(values=palette) +
  labs(x = "Adoption Speed", y = "", fill = "Type") +
  theme_minimal()


palette <- natparks.pals("Saguaro",n = 2)
pets_per_post <- ggplot(data_all, aes(x = Quantity, fill = Type)) +
  geom_histogram(binwidth = 1, color = "black", alpha = 0.7) +  
  scale_fill_manual(values = palette) +
  labs(title = "Number of Animals in Post",               
       x = "Quantity",                                           
       y = "Frequency",                                          
       fill = "Type") +                                          
  theme_classic() +                                              
  theme(axis.text.x = element_text(angle = 45, hjust = 1),             
    legend.position = "top")

rate_num_overview <- plot_grid(adoption_dist, pets_per_post, ncol = 2)

ggsave('work/results/figures/adoption_speed_quantity_all_data_overview.png', rate_num_overview)

## keep only entries where there is a single pet found
# for entries with multiple pets we don't know what the info is referring to
data_singles <- data_all %>% filter(Quantity == '1')

## keep data where more than one animal was found in case we want this 
data_multi <- data_all %>% filter(Quantity > '1')

palette <- natparks.pals("Arches",n = 4)

size_singles <- ggplot(data_singles %>% group_by(Type, MaturitySize) %>% count(), aes(x=Type, y = n, fill = MaturitySize)) + 
  geom_col(position = "stack") +
  labs(x = "Type", y = "Count", fill = "Size") +
  theme_classic() +
  scale_fill_manual(values=palette) +
  ggtitle("Size Breakdown")

make_stacked_bar_plot <- function(tallied_data, feature_name) {
  n_colors <- length(unique(tallied_data[[feature_name]]))
  palette <- natparks.pals("Arches", n = n_colors)
  
  ggplot(tallied_data, aes(x=Type, y = n, fill = tallied_data[[feature_name]])) +
    geom_col(position = "stack") +
    labs(x = "", y = "Number of Animals", fill = feature_name) +
    theme_classic() +
    scale_fill_manual(values=palette) +
    ggtitle(feature_name)
}

feature_columns <- c("Gender","MaturitySize", "FurLength", "Vaccinated", 
                     "Dewormed", "Sterilized", "Health")

plots <- lapply(feature_columns, function(feature) {
  make_stacked_bar_plot(data_singles %>% group_by(Type, .data[[feature]]) %>% count(), 
                        feature_name = feature)
})


# Create the grid with all plots
basic_overview_plts <- plot_grid(plotlist = plots, nrow = 2)

ggsave("work/results/figures/single_animals_overview_plots.png", basic_overview_plts)

# age distribution 
ggplot(data_singles) + 
  geom_violin(aes(x = Type, y = Age / 12, fill = Type)) +
  scale_fill_manual(values = c("#345023", "#596C0B")) + 
  labs(x = "", y = "Age in Years") +
  theme_classic()

## types of breeds 

data_singles %>% group_by(Type, BreedName_primary) %>% count() %>% arrange(desc(n))


# explore some other features of our data, like the names of the animals 
dog_name <- data_singles %>% filter(Type == 'Dog') %>%  group_by(Name) %>% count() %>% arrange(desc(n))

cat_name <- data_singles %>% filter(Type == 'Cat') %>%  group_by(Name) %>% count() %>% arrange(desc(n))

# removed the very first line bc it was 'unknown'
dog_names_plt <- ggplot(dog_name[2:30,]) + 
  geom_col(aes(x= reorder(Name, -n), y = n), fill = "#596C0B") + 
  theme_classic() +
  labs(x = "Dog Name", y = "Number of Dogs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# removed the very first line bc it was 'unknown'
cat_names_plt <- ggplot(cat_name[2:30,]) + 
  geom_col(aes(x= reorder(Name, -n), y = n), fill = "#345023") + 
  theme_classic() +
  labs(x = "Cat Name", y = "Number of Cats") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

dog_cat_names <- plot_grid(dog_names_plt, cat_names_plt, nrow = 2)
ggsave("work/results/figures/single_animals_top_cat_dog_names.png", dog_cat_names)


