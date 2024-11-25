## Predicting Dog and Cat Adoptability

This project utilizes data from PetFinder.com, that was downloaded from kaggle. The goal is to predict the time it takes for dogs to get adopted based on the information pulled from PetFinder.com which contains characteristics like age, breed, color, vacination status etc. This project makes use of R for data cleaning and visualization (dplyr, ggplot) and Python for building and testing machine learning models (PyCaret, Pandas). 

To get started, clone this repository using the following command line argument
```
git clone https://github.com/skpeterson/BIOS611_Pet_Adoption_Data_Project.git
```

To build the docker container, open your terminal, start a bash session, and run
```
bash build_docker.sh
```

To run the Docker container and get started, please run 
```
bash start_docker.sh
```

Now open your web browser, and open two tabs. The docker container runs both Rstudio and Python/Jupyter.
- To access Rstudio, navigate to localhost:8787. username: rstudio, password: benson
- To access Jupyter notebook go to http://<host_machine_ip>:8888/tree?token=<token> . Where <host machine IP> is the IP address of the machine running the Docker container, and the <token> can be found in the container log in the bash shell you started the container in.

Great!! You're in!!
