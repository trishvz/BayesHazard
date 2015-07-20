# File to be executed by R in batch mode.  The arguments to Stan are given
# on the command line (see the shell script "batch.sh."
args <- commandArgs(trailingOnly=TRUE)

# Indicate which model to fit
model <- args[1]

# Indicate towhich data set the model is to be fit, included as a list in
# simulations.Rdata
data.set <- args[2]

# Save the fits to output.file
output.file <- args[3]

# Specify the number of burnin samples
burn <- as.numeric(args[4])

# Specify the chain length after burnin
n.iter <- as.numeric(args[5])

# Specify the delta parameter for the NUTS sampler
adapt.delta <- as.numeric(args[6])

# Specify the number of chains
n.chains <- as.numeric(args[7])

# Clean up the args variable
rm(args)

# Read in simulated data for model fitting as the list "dat," with
# > names(dat)
# [1] "dat.50"  "dat.100" "dat.500"
load('simulations.Rdata')

# Load in pre-compiled Stan code containing the list "fit," with
# > names(fit)
# [1] "full" "null"
load('compiled.Rdata')

# Source the fit.model function 
source('fit_model.r')

# Fit the piecewise exponential model to the simulated data using the
# parameters specified on the command line.  The function fit.model will
# generate n.chains in parallel, so the number of processes spawned by
# fit.model will be n.chains.
fit.model(fit[[model]],dat[[data.set]],output.file,
          burn=burn,n.iter=n.iter,
          adapt.delta=adapt.delta,n.chains=n.chains)
