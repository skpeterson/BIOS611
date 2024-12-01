suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(NatParksPalettes)
  library(ggridges)
  library(cowplot)
  library(ggalluvial)
})

data_all <- read.csv('/home/rstudio/work/data/working_data/train_adoption_values_to_category_data.csv', sep = ',')

adopt_speed <- ggplot(data = data_all %>% group_by(Type,AdoptionSpeed) %>% count(),
       aes(axis1 = Type, axis2 = AdoptionSpeed, y = n)) +
  geom_alluvium(aes(fill = Type)) +
  geom_stratum() +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  scale_x_discrete(limits = c("Type", "AdoptionSpeed"), expand = c(0.2, 0.2)) +
  scale_fill_manual(values = c("#CD8A39", "#127088")) +
  labs(title = "Adoption Speed",
       x = "",
       y = "") +
  theme_void() + 
  theme(legend.position = "none")

pets_per_post <- ggplot(data_all, aes(x = Quantity, fill = Type)) +
  geom_histogram(binwidth = 1, color = "black", alpha = 0.7) +  
  scale_fill_manual(values = c("#CD8A39", "#127088")) +
  labs(title = "Animals Per Post",               
       x = "Quantity",                                           
       y = "Frequency",                                          
       fill = "Type") +                                          
  theme_classic() +                                              
  theme(axis.text.x = element_text(angle = 45, hjust = 1),             
    legend.position = "top")

rate_num_plts <- plot_grid(adopt_speed, pets_per_post, ncol = 2)
ggsave('/home/rstudio/work/results/figures/summary_vis/cat_dog_adopt_rate_quantity_per_post.png',rate_num_plts, units = 'in', width = 4.5, height = 3.5)

## keep only entries where there is a single pet found
# for entries with multiple pets we don't know what the info is referring to
data_singles <- data_all %>% filter(Quantity == '1')

## keep data where more than one animal was found in case we want this 
data_multi <- data_all %>% filter(Quantity > '1')

make_stacked_bar_plot <- function(tallied_data, feature_name) {
  n_colors <- length(unique(tallied_data[[feature_name]]))
  palette <- natparks.pals("Arches", n = n_colors)
  
  ggplot(tallied_data, aes(x=Type, y = n, fill = tallied_data[[feature_name]])) +
    geom_col(position = "stack") +
    labs(x = "", y = "Number of Animals", fill = NULL) +
    theme_classic() +
    scale_fill_manual(values=palette) +
    ggtitle(feature_name) +
    theme(
      text = element_text(size = 10),       
      axis.text = element_text(size = 8),   
      axis.title = element_text(size = 10), 
      legend.text = element_text(size = 8),
      plot.title = element_text(size = 12)  
    )
  }

feature_columns <- c("Gender","MaturitySize", "FurLength", "Vaccinated", 
                     "Dewormed", "Sterilized", "Health","Primary_Color")

plots <- lapply(feature_columns, function(feature) {
  make_stacked_bar_plot(data_singles %>% group_by(Type, .data[[feature]]) %>% count(), 
                        feature_name = feature)
})

# Create the grid with all plots
basic_overview_plts <- plot_grid(plotlist = plots, nrow = 4)

ggsave("/home/rstudio/work/results/figures/summary_vis/single_animals_overview_plots.png", basic_overview_plts, units = 'in', width = 5, height = 6.5)

## types of breeds 

breed_summary <- data_singles %>% group_by(Type,BreedName_primary) %>% count()

cat_breeds <- data_singles %>% filter(Type == 'Cat') %>% group_by(BreedName_primary) %>% count() %>% arrange(desc(n))
length(cat_breeds$BreedName_primary)
cat_breeds_filtered <- cat_breeds %>% filter(n > 2)

cat_breeds_barplt <- ggplot(cat_breeds_filtered, aes(x = reorder(BreedName_primary, n), y = log(n+1))) + # Reorder based on count (descending)
  geom_bar(stat = "identity", fill = "#CD8A39") +                 
  coord_flip() +                                 # Flip axes for better readability
  scale_y_continuous(labels = function(y) round(exp(y))) +
  labs(x = "Breed Name", y = "Log Number of Animals",        
       title = "Cat Breeds") +
  theme_minimal()

dog_breeds <- data_singles %>% filter(Type == 'Dog') %>% group_by(BreedName_primary) %>% count() %>% arrange(desc(n))
length(dog_breeds$BreedName_primary)
dog_breeds_filtered <- dog_breeds %>% filter(n > 5)

dog_breeds_barplt <- ggplot(dog_breeds_filtered, aes(x = reorder(BreedName_primary, n), y = log(n+1))) + # Reorder based on count (descending)
  geom_bar(stat = "identity", fill = "#127088") +                 
  coord_flip() + # Flip axes for better readability
  scale_y_continuous(labels = function(y) round(exp(y))) +
  labs(x = "", y = "Log Number of Animals",        
       title = "Dog Breeds") +
  theme_minimal()

breed_summary_plt <- ggplot(breed_summary, aes(x=Type, y=log(n), fill=Type)) + 
  geom_boxplot() +
  scale_fill_manual(values = c("#CD8A39", "#127088")) + 
  scale_y_continuous(labels = function(y) round(exp(y))) +
  labs(x = "", y = "Log Count Per Breed",        
       title = "Numer of Animals Per Breed") +
  theme_classic()

breed_summary_plts <- plot_grid(cat_breeds_barplt, dog_breeds_barplt, breed_summary_plt, ncol = 3, rel_widths = c(1.5,2,1.75))

ggsave('/home/rstudio/work/results/figures/summary_vis/top_dog_cat_breed_names_num_animals_per_breed_combined.png', breed_summary_plts, units = 'in', width = 10, height = 5)


## look at cost of animals 

palette <- natparks.pals("Saguaro", n = 2)
adoption_fee <- ggplot(data_all, aes(x = log2(Fee + 1), y = Type, fill = Type)) + 
  geom_density_ridges() +
  scale_fill_manual(values = palette) +
  labs(x = "Adoption Fee ($)", y = "", fill = "") +
  scale_x_continuous(labels = function(x) round(2^x - 1, 2)  # Convert log2 values back to original scale
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 10),       
    axis.text = element_text(size = 6),   
    axis.title.x = element_text(size = 6), 
    legend.text = element_text(size = 6),
    legend.key.size = unit(0.2, "cm"),
    plot.margin = unit(c(0.1, 0.1, 0.1, 0.1), "cm")
  )

ggsave('/home/rstudio/work/results/figures/summary_vis/adoption_fee_distribution.png', adoption_fee, units = 'in', width = 2, height = 1.5)



# age distribution 
age_dist <- ggplot(data_singles) + 
  geom_violin(aes(x = Type, y = Age / 12, fill = Type)) +
  scale_fill_manual(values = c("#345023", "#596C0B")) + 
  labs(x = "", y = "Age in Years") +
  theme_classic() + 
  theme(
    legend.key.size = unit(0.3, "cm")
  )


# explore some other features of our data, like the names of the animals 
dog_name <- data_singles %>% filter(Type == 'Dog') %>%  group_by(Name) %>% count() %>% arrange(desc(n))

cat_name <- data_singles %>% filter(Type == 'Cat') %>%  group_by(Name) %>% count() %>% arrange(desc(n))

# removed the very first line bc it was 'unknown'
dog_names_plt <- ggplot(dog_name[2:30,]) + 
  geom_col(aes(x= reorder(Name, -n), y = n), fill = "#596C0B") + 
  theme_classic() +
  labs(x = "Dog Name", y = "Number of Dogs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 8),
        axis.title.y = element_text(size = 8))

# removed the very first line bc it was 'unknown'
cat_names_plt <- ggplot(cat_name[2:30,]) + 
  geom_col(aes(x= reorder(Name, -n), y = n), fill = "#345023") + 
  theme_classic() +
  labs(x = "Cat Name", y = "Number of Cats") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 8),
        axis.title.y = element_text(size = 8))

dog_cat_names <- plot_grid(dog_names_plt, cat_names_plt, nrow = 2)
dog_cat_names_ages <- plot_grid(dog_cat_names, age_dist, ncol = 2, rel_widths = c(2,1))
ggsave("/home/rstudio/work/results/figures/summary_vis/single_animals_top_cat_dog_names_ages.png", dog_cat_names_ages)


