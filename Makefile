.PHONY: clean init all

clean:
	rm -f /home/rstudio/work/results/figures/*/*
	rm -f /home/rstudio/work/data/working_data/*

init:
	mkdir -p /home/rstudio/work/data/working_data
	mkdir -p /home/rstudio/work/results/figures/summary_vis
	mkdir -p /home/rstudio/work/results/figures/ada_model
	mkdir -p /home/rstudio/work/results/figures/gbc_model
	mkdir -p /home/rstudio/work/results/figures/rf_model

all: /home/rstudio/work/results/report/Summary_Report.html

/home/rstudio/work/data/working_data/train_adoption_values_to_category_data.csv: /home/rstudio/work/scripts/clean_data.R \
    /home/rstudio/work/data/source_data/breed_labels.csv \
    /home/rstudio/work/data/source_data/color_labels.csv \
    /home/rstudio/work/data/source_data/state_labels.csv \
    /home/rstudio/work/data/source_data/petfinder_train_dataset.csv
	Rscript /home/rstudio/work/scripts/clean_data.R

/home/rstudio/work/results/figures/summary_vis/cat_dog_adopt_rate_quantity_per_post.png \
/home/rstudio/work/results/figures/summary_vis/single_animals_overview_plots.png \
/home/rstudio/work/results/figures/summary_vis/adoption_fee_distribution.png \
/home/rstudio/work/results/figures/summary_vis/top_dog_cat_breed_names_num_animals_per_breed_combined.png \
/home/rstudio/work/results/figures/summary_vis/single_animals_top_cat_dog_names_ages.png: /home/rstudio/work/scripts/visualize_data.R \
    /home/rstudio/work/data/working_data/train_adoption_values_to_category_data.csv
	Rscript /home/rstudio/work/scripts/visualize_data.R

/home/rstudio/work/data/working_data/filtered_transformed_prediction_data.csv \
/home/rstudio/work/data/working_data/filtered_transformed_training_data.csv: scripts/prepareData_compareModels.ipynb \
    /home/rstudio/work/data/source_data/petfinder_train_dataset.csv
	jupyter nbconvert --to notebook --execute /home/rstudio/work/scripts/prepareData_compareModels.ipynb

/home/rstudio/work/results/figures/ada_model/Feature_Importance.png \
/home/rstudio/work/results/figures/ada_model/Confusion_Matrix.png \
/home/rstudio/work/results/figures/gbc_model/Feature_Importance.png \
/home/rstudio/work/results/figures/gbc_model/Confusion_Matrix.png \
/home/rstudio/work/results/figures/rf_model/Feature_Importance.png \
/home/rstudio/work/results/figures/rf_model/Confusion_Matrix.png: /home/rstudio/work/scripts/tune_visualize_top_models.ipynb \
    /home/rstudio/work/data/working_data/filtered_transformed_training_data.csv \
    /home/rstudio/work/data/working_data/filtered_transformed_prediction_data.csv
	jupyter nbconvert --to notebook --execute /home/rstudio/work/scripts/tune_visualize_top_models.ipynb

/home/rstudio/work/results/report/Summary_Report.html: /home/rstudio/work/results/report/Summary_Report.Rmd \
    /home/rstudio/work/data/working_data/train_adoption_values_to_category_data.csv \
    /home/rstudio/work/results/figures/summary_vis/cat_dog_adopt_rate_quantity_per_post.png \
    /home/rstudio/work/results/figures/summary_vis/single_animals_overview_plots.png \
    /home/rstudio/work/results/figures/summary_vis/adoption_fee_distribution.png \
    /home/rstudio/work/results/figures/summary_vis/top_dog_cat_breed_names_num_animals_per_breed_combined.png \
    /home/rstudio/work/results/figures/summary_vis/single_animals_top_cat_dog_names_ages.png \
    /home/rstudio/work/results/figures/ada_model/Confusion_Matrix.png \
    /home/rstudio/work/results/figures/ada_model/Feature_Importance.png \
    /home/rstudio/work/results/figures/gbc_model/Confusion_Matrix.png \
    /home/rstudio/work/results/figures/gbc_model/Feature_Importance.png \
    /home/rstudio/work/results/figures/rf_model/Confusion_Matrix.png \
    /home/rstudio/work/results/figures/rf_model/Feature_Importance.png
    
	Rscript -e 'rmarkdown::render("/home/rstudio/work/results/report/Summary_Report.Rmd", output_format = "html_document")'
