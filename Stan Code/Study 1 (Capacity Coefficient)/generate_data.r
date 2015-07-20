# This function generates simulated data for 4 subjects following the
# parameterizations described in Houpt et al. (2015), Table 3.  The samples
# t.i1, t.i2 and t.i3 represent the conditions u(dot), (dot)v, and uv,
# respectively.  The argument n is the sample size for each condition by
# subject, and defaults to 50.

generate.data <- function(n=50) {
    # The library 'SuppDists' contains the Wald (inverse normal)
    # distribution (r, d, p, q) functions.
    library(SuppDists)

    # Generate data for Model 1 (minimum gamma)
    t.11 <- rgamma(n,2,1)
    t.12 <- rgamma(n,2,1)
    t.13 <- apply(cbind(rgamma(n,2,1),rgamma(n,2,1)),1,min)

    # Generate data for Model 2 (product of lognormals)
    t.21 <- rlnorm(n,0,1)
    t.22 <- rlnorm(n,0,1)
    t.23 <- rlnorm(n,0,1)*rlnorm(n,0,1)

    # Generate data for Model 3 (inverse normal with coactivation)
    nu.1 <- 1.5
    nu.2 <- 1.5
    alpha <- 20
    diff <- 1 # drift coefficient
    t.31 <- rinvGauss(n, nu=alpha/(nu.1), lambda=.5*(alpha/diff)^2)
    t.32 <- rinvGauss(n, nu=alpha/(nu.2), lambda=.5*(alpha/diff)^2)
    t.33 <- rinvGauss(n, nu=alpha/(nu.2+nu.1), lambda=.5*(alpha/diff)^2)
    
    # Generate data for Model 4 (maximum exponential)
    t.41 <- rexp(n,rate=.5)
    t.42 <- rexp(n,rate=.4)
    t.43 <- apply(cbind(rexp(n,rate=.4),rexp(n,rate=.5)),1,max)

    # Construct the data list as required by stan.  This requires defining the
    # following variables:
    # Variable            Description
    # -------------------------------
    # levels              number of conditions (levels) for each
    #                     subject (model)
    # Nsub                number of subjects
    # N                   sample size, total number of observations
    #                     over subjects and levels
    # X                   condition identification (1, 2 or 3; vector
    #                     of length N)
    # isub                subject identification (vector of length N)
    # t                   observed response times (vector of length N)
    # J                   number of time bins (see Figure 1)
    # s                   bin boundaries (quantiles)
    # common_s            bin boundaries computed to be the same
    #                     over each condition (used for the
    #                     unlimited capacity null model

    levels <- 3
    isub <- as.numeric(c(rep(1,times=levels*n), 
              rep(2,times=levels*n),
              rep(3,times=levels*n),
              rep(4,times=levels*n)))
    t <- c(t.11,t.12,t.13,
           t.21,t.22,t.23,
           t.31,t.32,t.33,
           t.41,t.42,t.43)
    N <- length(t)
    Nsub <- length(unique(isub))
    X <- rep(c(rep(1,times=n),
               rep(2,times=n),
               rep(3,times=n)),times=Nsub)
    
    # Define the quantiles to be used as bin boundaries; this could
    # potentially be an argument passed to generate.data.  The number of
    # quantiles will determine the number of bins J.
    qs <- seq(.1,.9,by=.1)
    J <- length(qs)+1

    # Compute values for s[J], the last bin boundary
    maxes <- 1.05*aggregate(t,by=list(X,isub),max)$x
    common.maxes <- 1.05*aggregate(t,by=list(isub),max)$x

    # Compute the central bin boundaries as quantiles
    s <- aggregate(t,by=list(X,isub),quantile,qs)$x
    s <- cbind(0,s,maxes)
    common.s <- aggregate(t,by=list(isub),quantile,qs)$x
    common.s <- cbind(0,common.s,common.maxes)

    # Reshape s and common.s as arrays over subjects and levels
    s <- array(s,dim=c(levels,Nsub,(J+1)))
    common.s <- array(common.s[rep(1:Nsub,each=levels),],
                      dim=c(levels,Nsub,(J+1)))

    # Data list for model_script.stan
    dat <- list(N=N,
                levels=levels,
                Nsub=Nsub,
                J=J,
                t=t,
                s=s,
                common_s=common.s,
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
