FROM debian:12

# Install BEAST, R, and treeio R package
RUN apt-get update && apt-get install -y r-base beast-mcmc wget
RUN R -e "install.packages('BiocManager', repos='http://cran.us.r-project.org'); BiocManager::install('treeio')"

# Install Julia and Julia packages
RUN wget https://julialang-s3.julialang.org/bin/linux/aarch64/1.9/julia-1.9.3-linux-aarch64.tar.gz && \
    tar -xzf julia-1.9.3-linux-aarch64.tar.gz && \
    rm julia-1.9.3-linux-aarch64.tar.gz && \
    mv julia-1.9.3 /opt/julia-1.9.3 && \
    echo "export PATH=$PATH:/opt/julia-1.9.3/bin" >> ~/.bashrc
RUN /opt/julia-1.9.3/bin/julia -e 'import Pkg; Pkg.add(["CSV", "DataFrames", "StatsPlots"])'

# Load source code
COPY src /src

# Set working directory
WORKDIR /src
