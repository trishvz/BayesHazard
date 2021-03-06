# This function generates simulated data for 5 subjects following the
# parameterizations described in Houpt et al. (2015), Table 4.  The samples
# t.i1, t.i2, t.i3 and t.i4 represent the conditions ss, sf, fs and ff,
# respectively.  The argument n is the sample size for each condition by
# subject, and defaults to 50.

generate.data <- function(n=50) {
    # The library 'SuppDists' contains the Wald (inverse normal)
    # distribution (r, d, p, q) functions.
    library(SuppDists)

    # Generate data for Model 1 (serial AND)
    t.11 <- rgamma(n,4,1.5)+rgamma(n,4,1.5)
    t.12 <- rgamma(n,1,1.5)+rgamma(n,4,1.5)
    t.13 <- rgamma(n,4,1.5)+rgamma(n,1,1.5)
    t.14 <- rgamma(n,1,1.5)+rgamma(n,1,1.5)

    # Generate data for Model 2 (lognormal serial OR)
    h.1 <- .5
    h.2 <- 1
    l.1 <- -1.5
    l.2 <- -.5
    # Note that this is a mixture model with mixing probability 0.5
    flag <- runif(n)<.5
    t.21 <- flag*rlnorm(n,l.1,1) + (1-flag)*rlnorm(n,l.2,1)
    flag <- runif(n)<.5
    t.22 <- flag*rlnorm(n,l.1,1) + (1-flag)*rlnorm(n,h.2,1)
    flag <- runif(n)<.5
    t.23 <- flag*rlnorm(n,h.1,1) + (1-flag)*rlnorm(n,l.2,1)
    flag <- runif(n)<.5
    t.24 <- flag*rlnorm(n,h.1,1) + (1-flag)*rlnorm(n,h.2,1)

    # Generate data for Model 3 (Weibull parallel OR)
    t.31 <- apply(cbind(rweibull(n,3,3),rweibull(n,3,3)),1,min)
    t.32 <- apply(cbind(rweibull(n,3,3),rweibull(n,3,6)),1,min)
    t.33 <- apply(cbind(rweibull(n,3,3),rweibull(n,3,6)),1,min)
    t.34 <- apply(cbind(rweibull(n,3,6),rweibull(n,3,6)),1,min)

    # Generate data for Model 4 (Gamma parallel AND)
    t.41 <- apply(cbind(rgamma(n,3,.5),rgamma(n,3,.5)),1,max)
    t.42 <- apply(cbind(rgamma(n,3,.5),rgamma(n,3,1.5)),1,max)
    t.43 <- apply(cbind(rgamma(n,3,.5),rgamma(n,3,1.5)),1,max)
    t.44 <- apply(cbind(rgamma(n,3,1.5),rgamma(n,3,1.5)),1,max)

    # Generate data for Model 5 (inverse normal with coactivation)
    nu.l <- 1.5
    nu.h <- 3
    alpha <- 20
    diff <- 1 # drift coefficient
    t.51 <- rinvGauss(n, nu=alpha/(nu.l+nu.l), lambda=.5*(alpha/diff)^2)
    t.52 <- rinvGauss(n, nu=alpha/(nu.h+nu.l), lambda=.5*(alpha/diff)^2)
    t.53 <- rinvGauss(n, nu=alpha/(nu.l+nu.h), lambda=.5*(alpha/diff)^2)
    t.54 <- rinvGauss(n, nu=alpha/(nu.h+nu.h), lambda=.5*(alpha/diff)^2)

    # Construct the data list as required by stan.  This requires defining the
    # following variables:
    # Variable            Description
    # -------------------------------
    # levels              number of conditions (levels) for each
    #                     subject (model)
    # Nsub                number of subjects
    # N                   sample size, total number of observations
    #                     over subjects and levels
    # X                   condition identification (1, 2, 3 or 4; vector
    #                     of length N)
    # isub                subject identification (vector of length N)
    # t                   observed response times (vector of length N)
    # J                   number of time bins (see Figure 1)
    # s                   bin boundaries (quantiles)

    levels <- 4

    isub <- as.numeric(c(rep(1,times=levels*n),
                 rep(2,times=levels*n),
                 rep(3,times=levels*n),
                 rep(4,times=levels*n),
                 rep(5,times=levels*n)))
    t <- c(t.11,t.12,t.13,t.14,
           t.21,t.22,t.23,t.24,
           t.31,t.32,t.33,t.34,
           t.41,t.42,t.43,t.44,
           t.51,t.52,t.53,t.54)
    N <- length(t)
    Nsub <- length(unique(isub))
    X <- rep(c(rep(1,times=n),
               rep(2,times=n),
               rep(3,times=n),
               rep(4,times=n)),times=Nsub)

    # Define the quantiles to be used as bin boundaries; this could
    # potentially be an argument passed to generate.data.  The number of
    # quantiles will determine the number of bins J.
    qs <- seq(.1,.9,by=.1)
    J <- length(qs)+1

    # Compute values for s[J], the last bin boundary
    maxes <- 1.05*aggregate(t,by=list(X,isub),max)$x

    # Compute the central bin boundaries as quantiles
    s <- aggregate(t,by=list(X,isub),quantile,qs)$x
    s <- cbind(0,s,maxes)

    # Reshape s as an array over subjects and levels
    s <- array(s,dim=c(levels,Nsub,(J+1)))

    # Data list for model_script.stan
    dat <- list(N=N,
                levels=levels,
                Nsub=Nsub,
                J=J,
                t=t,
                s=s,
                X=X,
                max_t=maxes,
                isub=isub)

return(dat)
}

# Generate data sets for three sample sizes, 50, 100 and 500 
dat.50 <- generate.data(50)
dat.100 <- generate.data(100)
dat.500 <- generate.data(500)
dat <- list(dat.50=dat.50,dat.100=dat.100,dat.500=dat.500)
save(dat,file='simulations.Rdata')
