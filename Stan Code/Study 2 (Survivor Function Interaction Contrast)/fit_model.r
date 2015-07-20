# Function to call Stan for model fitting.  All the real action is in this
# function, which is called from cc.r.  The model code is assumed to be
# compiled already.
#
# Arguments        Description
# --------------------------------------------------
# model.name       Model to be fit, "full" or "null"
# data.set         Simulated data set to which the model will be fit, "dat.50,"
#                  "dat.100," or "dat.500"
# output.file      Name of the file in which chains will be stored
# burn             number of burnin samples
# n.iter           number of samples in each chain after burnin
# adapt.delta      value of NUTS adaptation parameter delta
# n.chains         number of chains
fit.model <- function(model.name,data.set,output.file,
                      burn=10,n.iter=10,
                      adapt.delta=.8,n.chains=3) {
#  Required libraries
   library(rstan)
   library(parallel)

#  Read in value of random number seed (for debugging)   
   source('seed.r')
#  Spawn n.chains processes, one for each chain, and collect the results
#  in list sflist.  The function "sampling" is an rstan routine (see pg. 24
#  of the Rstan manual).
   sflist <-
        mclapply(1:n.chains,mc.cores=n.chains,
                 function(i) sampling(model.name,data=data.set,
                               seed=rng.seed,
                               diagnostic_file='diag',
                               iter = n.iter+burn,
                               warmup=burn,
                               control=list(adapt_delta=adapt.delta),
                               chains = 1,
                               chain_id=i,
                               refresh=-1))
   
# Merge the list of stanfit objects in sflist into a single stanfit object
   fit <- sflist2stanfit(sflist)
# Save the chains in output.file   
   save(fit,data.set,file=output.file)
}
