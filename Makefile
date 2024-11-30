.PHONY clean init

clean:
	rm -rf results/figures/*
	rm -rf data/working_data/*

init:
	mkdir -p data/working_data
	mkdir -p results/figures/summary_vis
	mkdir -p results/figures/ada_model
	mkdir -p results/figures/gbc_model
	mkdir -p results/figures/rf_model

data/working_data/train_adoption_values_to_category_data.csv: scripts/clean_data.R data/source_data/breed_labels.csv data/source_data/color_labels.csv data/source_data/state_labels.csv data/source_data/petfinder_train_dataset.csv
       Rscript scripts/clean_data.R

results/figures/summary_vis/cat_dog_adopt_rate_quantity_per_post.png: scripts/visualize_data.R data/working_data/train_adoption_values_to_category_data.csv
	Rscript scripts/visualize_data.R

results/figures/summary_vis/single_animals_overview_plots.png: scripts/visualize_data.R data/working_data/train_adoption_values_to_category_data.csv
        Rscript scripts/visualize_data.R

results/figures/summary_vis/adoption_fee_distribution.png: scripts/visualize_data.R data/working_data/train_adoption_values_to_category_data.csv
        Rscript scripts/visualize_data.R

results/figures/summary_vis/top_dog_cat_breed_names_num_animals_per_breed_combined.png: scripts/visualize_data.R data/working_data/train_adoption_values_to_category_data.csv
        Rscript scripts/visualize_data.R

results/figures/summary_vis/single_animals_top_cat_dog_names_ages.png: scripts/visualize_data.R data/working_data/train_adoption_values_to_category_data.csv
        Rscript scripts/visualize_data.R
        

results/report/Summary_Report.Rmd: data/working_data/train_adoption_values_to_category_data.csv \
        results/figures/summary_vis/cat_dog_adopt_rate_quantity_per_post.png \
        results/figures/summary_vis/single_animals_overview_plots.png \
        results/figures/summary_vis/adoption_fee_distribution.png \
        results/figures/summary_vis/top_dog_cat_breed_names_num_animals_per_breed_combined.png \
        results/figures/summary_vis/single_animals_top_cat_dog_names_ages.png \
        results/figures/gbc_model/Confusion_Matrix.png \
        results/figures/gbc_model/Feature_Importance.png \
        results/figures/rf_model/Confusion_Matrix.png \
        results/figures/rf_model/Feature_Importance.png \
        results/figures/ada_model/Confusion_Matrix.png \
        results/figures/ada_model/Feature_Importance.png
        
        Rscript -e 'rmarkdown::render("results/report/Summary_Report.Rmd")'

