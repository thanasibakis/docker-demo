# This doesn't do anything meaningful, it's just to demo a pipeline in Docker

using CSV, DataFrames, StatsPlots

df = CSV.read("data.csv", DataFrame)
p  = scatter(df[!, :rate])

png(p, "plot.png")

println("You might have seen a bunch of scary messages about Qt, but if you got a plot.png file, you're good!")
