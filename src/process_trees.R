# This doesn't do anything meaningful, it's just to demo a pipeline in Docker

suppressPackageStartupMessages(library(treeio))

trees <- read.beast("example.trees")
get.data(trees[[1]]) |> write.csv("data.csv")
