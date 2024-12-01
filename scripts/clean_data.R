suppressPackageStartupMessages({
  library(here)
  library(dplyr)
})

data <- read.csv('/home/rstudio/work/data/source_data/petfinder_train_dataset.csv',sep=',')
breed_labels <- read.csv('/home/rstudio/work/data/source_data/breed_labels.csv')
color_labels <- read.csv('/home/rstudio/work/data/source_data/color_labels.csv')
no_color <- data.frame(ColorID = 0, ColorName = NA)
color_labels <- rbind(color_labels, no_color)
state_labels <- read.csv('/home/rstudio/work/data/source_data/state_labels.csv')


# Convert columns to appropriate data types and give factors meaning 
data$Type <- factor(data$Type, labels = c("Dog", "Cat"))
data$Gender <- factor(data$Gender, labels = c("Male", "Female", "Mixed"))
data$MaturitySize <- factor(data$MaturitySize, levels = c(0, 1, 2, 3, 4), labels = c("Not Specified", "Small", "Medium", "Large", "Extra Large"))
data$FurLength <- factor(data$FurLength, levels = c(0, 1, 2, 3), labels = c("Not Specified", "Short", "Medium", "Long"))
data$Vaccinated <- factor(data$Vaccinated, levels = c(1, 2, 3), labels = c("Yes", "No", "Not Sure"))
data$Dewormed <- factor(data$Dewormed, levels = c(1, 2, 3), labels = c("Yes", "No", "Not Sure"))
data$Sterilized <- factor(data$Sterilized, levels = c(1, 2, 3), labels = c("Yes", "No", "Not Sure"))
data$Health <- factor(data$Health, levels = c(0, 1, 2, 3), labels = c("Not Specified", "Healthy", "Minor Injury", "Serious Injury"))

# turn breed from numbers to names 
data <- data %>%
  left_join(breed_labels, by = c("Breed1" = "BreedID")) %>%
  rename(BreedName_primary = BreedName) %>%
  left_join(breed_labels, by = c("Breed2" = "BreedID")) %>%
  rename(BreedName_secondary = BreedName) %>% 
  select(-c(Type.y, Type))
colnames(data)[colnames(data) == "Type.x"] <- "Type"

# turn colors from numbers to names 

# Map Color1 to ColorName
data <- merge(data, color_labels, by.x = "Color1", by.y = "ColorID", all.x = TRUE)
# Rename the new column for clarity
colnames(data)[colnames(data) == "ColorName"] <- "Primary_Color"

# Map Color2 to ColorName
data <- merge(data, color_labels, by.x = "Color2", by.y = "ColorID", all.x = TRUE)
# Rename the new column for clarity
colnames(data)[colnames(data) == "ColorName"] <- "Second_color"

# Map Color3 to ColorName
data <- merge(data, color_labels, by.x = "Color3", by.y = "ColorID", all.x = TRUE)
# Rename the new column for clarity
colnames(data)[colnames(data) == "ColorName"] <- "Third_Color"

# map state ID to actual state label
data <- merge(data, state_labels, by.x = 'State', by.y = 'StateID', all.x = TRUE)

# let's handle dogs not having a name 
# Replace empty or missing values in the Name column with "Unknown"
data$Name[is.na(data$Name) | data$Name == ""] <- "Unknown"

# let's keep only the columns we want for visualization purposes 

data_viz <- data %>% select(-c('Color1', 'Color2','Color3',
                               'Breed1','Breed2','RescuerID',
                               'VideoAmt','Description','PhotoAmt'))

# quickly check the name category to see if we need to clean 
data_viz %>% group_by(Type,Name) %>% count() %>% arrange(desc(n)) %>% print(n=30)

# check least common names out of curiosity, they all appear to be descriptions more than names, but we won't fix these 
data_viz %>% group_by(Type,Name) %>% count() %>% arrange(desc(-n)) %>% print(n=50)

# Name contains Unknown as well as No Name and Kittens, make these unknown for consistency
data_viz$Name[data_viz$Name %in% c('No Name', 'Kittens','Puppy')] <- 'Unknown'


# some animals are more than 1, but mostly its 1 cat or dog in each listing
data_viz %>% group_by(Type, Quantity) %>% count() %>% print(n=30)

# let's write this data out so we can use it for visualization 
write.csv(data_viz, file = '/home/rstudio/work/data/working_data/train_adoption_values_to_category_data.csv', row.names = F)
