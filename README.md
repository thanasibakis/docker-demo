# Docker demo for the Minin Lab

## Why Docker?

I've set up a small pipeline that mimics how one might analyze genomic data:
- Run BEAST to obtain tree samples
- Process the BEAST trees in R
- Do some computation and visualization in Julia

(Note that the code in this repository is just a toy example, and does nothing scientifically meaningful.)

Typically, if you wanted to run this pipeline of mine in a reproducible manner, you'd have to:
- Install the versions of BEAST, R, and Julia that I used
- Install the R and Julia packages that I used

To save the state of my R and Julia package installations, we usually use [renv](https://rstudio.github.io/renv/articles/renv.html) or [Julia's built-in environment system](https://pkgdocs.julialang.org/v1/environments/).

Essentially, the complexity of reproducing my work grows with the complexity of my pipeline.
Can we make this easier?

## Using Docker

Before anything, install [Docker Desktop](https://www.docker.com/products/docker-desktop/).

The repository contains a Dockerfile, which is a script that Docker reads to set up all the pipeline's dependencies.
This will create a *container* for us, which (for our purposes) is essentially a virtual machine, having our entire pipeline pre-installed.

Docker breaks this process into two steps:
1. Build an *image* from the Dockerfile, which is like a blueprint for containers.
2. Create and start a *container* from the image.

### Building the image

To build an image, Docker starts with a base container (whichever is listed as the `FROM` line in your Dockerfile), reads the Dockerfile, and executes each line in the context of the base container.
It will then save the resulting container as an image, so we can create as many containers with this pipeline as we want, without having to reinstall the dependencies every time.

To build the image, run:

```
docker image build --tag stats-demo github.com/thanasibakis/docker-demo
```

(Docker will automatically clone the repository for you and look for the Dockerfile at the repository root.)

To view the image you just created, run:

```
docker image ls
```

### Creating and starting a container

To create and start a container from the image, run:

```
docker container run -it --name my-cool-container stats-demo
```

You will then be dropped onto a command prompt running *inside the container*!
You can now run any of the commands in the pipeline, and they will work as if you had installed all the dependencies yourself.

For this pipeline, try:

```
beast-mcmc beast.xml
Rscript process_trees.R
julia visualize.jl
```

To stop and exit the container, type `exit` at the command prompt.

To view a list of containers, you've created, run one of:

```
docker container ls -a  # all containers
docker container ls     # currently running containers only
```

To restart and re-enter a container you've already created, run:

```
docker container start -i <container ID or name>
```

To remove a stopped container, run one of:

```
docker container rm <container ID or name>  # removes a specific container
docker container prune                      # removes all stopped containers
```

### Moving files between the host and the container

Once you've run the pipeline, you probably want to save the results somewhere on your regular computer.

To do this, we need to move the files from the container to the host:

```
docker container cp <container ID or name>:/src/plot.png ./plot.png
```

What we can also do is mount a folder on the host as a folder inside the container.
If you're unfamiliar with the concept of mounting, think of it as "syncing" a folder between the two.
The catch is, we must set up the mount before the container is created.

To do this, run:

```
docker container run -it --name even-cooler-container -v ./from-container:/src/to-host stats-demo
```

Now, any file you create in the `src` folder inside the container will be synced to the `from-container` folder on your host computer, and vice versa.
(Of course, you can change the name of the `from-container` to whatever you want.)

## Developing with Docker

Docker doesn't have to be only for running the pipeline after it's built.
You can use a container to develop your code as well!

The first step is to manually clone the repository you want to work on:

```
git clone https://github.com/thanasibakis/docker-demo.git
```

Then, we can build an image from the local Dockerfile.
First, `cd` into the repository root, then run:

```
docker image build --tag stats-demo .  # Don't forget the dot!
```

Finally, we will create a container, but mounting the code folder in the repository to the equivalent folder inside the container:

```
docker container run -it --name development-container -v ./src:/src stats-demo
```

Now, any edits to the code in the `src` folder on your host computer will be synced to the `src` folder inside the container, and vice versa.

**Note:** this will only be true for this specific container (`development-container`).
Any other containers you create that don't also have this mount will use the same version of the code that was present when the image was built.
(Of course, you can always rebuild the image and create new containers.)
