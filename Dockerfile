FROM rocker/verse
RUN apt update && apt install -y man && rm -rf /var/lib/apt/lists/*