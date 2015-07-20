# This batch file (1) generates simulated data as described in
# generate_data.r, (2) compiles the Stan code for model fitting and (3)
# calls R for each model and each sample size to fit the models to each
# data set.  Please see the comments in files sic.r and fit_model.r for more
# information.
#
# If data are already generated, comment out the next line:
R CMD BATCH generate_data.r generate_data.r.Rout
# If models are already compiled, comment out the next line:
R CMD BATCH compile_models.r compile_models.r.Rout
R CMD BATCH "--args full dat.50 sic_50.Rdata 1000 10000 .99 3" sic.r sic_50.r.Rout &
R CMD BATCH "--args full dat.100 sic_100.Rdata 1000 10000 .99 3" sic.r sic_100.r.Rout &
R CMD BATCH "--args full dat.500 sic_500.Rdata 1000 10000 .99 3" sic.r sic_500.r.Rout &

