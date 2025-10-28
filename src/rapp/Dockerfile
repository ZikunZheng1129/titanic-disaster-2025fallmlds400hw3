# src/rapp/Dockerfile
FROM r-base:4.3.1
WORKDIR /app

# keep install_packages.R (required by assignment)
COPY src/rapp/install_packages.R /app/install_packages.R
RUN Rscript /app/install_packages.R

# copy R app
COPY src/rapp /app/src/rapp

# run the script
CMD ["Rscript", "src/rapp/main.R"]