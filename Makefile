.PHONY clean init

init:
	mkdir results
	mkdir working_data 

clean:
	rm -rf results/*
	rm -rf working_data/*
	rm -f Summary.Rmd

Summary.Rmd:
	Rscript -e 'rmkarkdown::render('Summary.Rmd')

