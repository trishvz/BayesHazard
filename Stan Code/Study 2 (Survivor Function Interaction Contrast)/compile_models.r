# Compile the model specified in the 'model_script.stan' file and save the
# result in name <- 'compiled.Rdata.'  This function is necessary when the
# computations are to be performed on different machines.  The model must
# be compiled on the same machine that later uses the code for sampling.
compile.models <- function(name) {
    # Rstan library is necessary
    library(rstan)
    # The Rstan function stan_model compiles the code passed as an argument
    full <- stan_model(file='model_script.stan')
    # Save the compiled code as a list in output file name.
    fit <- list(full=full)
    save(fit=fit,file=name)
}

# Execute the function compile.models using the argument name <-
# 'compiled.Rdata.'  This might be changed if several versions of the
# compiled code are desired for running on different machines.
name <- 'compiled.Rdata'
compile.models(name)
