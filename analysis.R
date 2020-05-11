library(openxlsx)
library(brms)

#### DATA CLEANING
# load data
d <- read.xlsx("data/final.xlsx", sheet = "Blad1", )

# Make sure decimal is . and not , and that we set var as numeric
d$Yrs <- as.numeric(gsub(",", ".", d$Yrs))

# scale Yrs for easier MCMC sampling, i.e. (\mu - x)/sd(x)
d$Yrs_s <- scale(d$Yrs)
#### END DATA CLEANING

#### MODEL DESIGN
# Seconds as outcome and Yrs, Corr, Ver as predictors (gaussian likelihood)
m_sec <- brm(Sec ~ 1 + Yrs + Corr + mo(Ver), family = gaussian, data = d, 
          cores = 4)

# Corr as outcome and Yrs and Ver as pred (bernoulli likelihood)
m_pass <- brm(Corr ~ 1 + Yrs + mo(Ver), family = bernoulli, data = d, cores = 4)

# Let's use Ver as a varying intercept and compare out of sample pred
m_sec_vi <- brm(Sec ~ 1 + Yrs + Corr + (1 | Ver), family = gaussian, data = d, 
             cores = 4, control = list(adapt_delta = 0.99))

m_pass_vi <- brm(Corr ~ 1 + Yrs + (1 | Ver), family = bernoulli, data = d, 
                 cores = 4, control = list(adapt_delta = 0.99), iter = 5e3)
#### END

#### MODEL COMPARISON
# Running the below clearly shows there is no diff in out of sample prediction.
# Hence we go for using m_sec and m_pass. Next we'll set priors
loo_compare(loo(m_sec), loo(m_sec_vi))
loo_compare(loo(m_pass), loo(m_pass_vi))
#### END

#### PRIOR PREDICTIVE CHECKS
# Get priors for each model and set sane priors
p_sec <- get_prior(Sec ~ 1 + Yrs + Corr + mo(Ver), family = lognormal, data = d)

p_sec$prior[1] <- "normal(0,1)"
p_sec$prior[5] <- "normal(0,5)"
p_sec$prior[6] <- "weibull(2,1)"
p_sec$prior[7] <- "dirichlet(2,2)"

M_sec <- brm(Sec ~ 1 + Yrs + Corr + mo(Ver), family = lognormal, data = d, 
             cores = 4, prior = p_sec, sample_prior = "only")
# so the above looks good when we check with conditional_effects(M_sec)
# Now let's run the model with new priors *and* data
M_sec <- brm(Sec ~ 1 + Yrs + Corr + mo(Ver), family = lognormal, data = d, 
             cores = 4, prior = p_sec)

# next model
p_pass <- get_prior(Corr ~ 1 + Yrs + mo(Ver), family = bernoulli, data = d)

p_pass$prior[1] <- "normal(0,1)"
p_pass$prior[4] <- "normal(0,5)"
p_pass$prior[5] <- "dirichlet(2,2)"

M_pass <- brm(Corr ~ 1 + Yrs + mo(Ver), family = bernoulli, data = d, cores = 4,
              prior = p_pass, sample_prior = "only")
# so the above looks good when we check with conditional_effects(M_pass)
# Now let's run the model with new priors *and* data

M_pass <- brm(Corr ~ 1 + Yrs + mo(Ver), family = bernoulli, data = d, cores = 4,
              prior = p_pass)


conditional_effects(M_sec)

conditional_effects(M_pass)

summary(M_sec)
# Family: lognormal 
# Links: mu = identity; sigma = identity 
# Formula: Sec ~ 1 + Yrs + Corr + mo(Ver) 
# Data: d (Number of observations: 35) 
# Samples: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
# total post-warmup samples = 4000
# 
# Population-Level Effects: 
#           Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
# Intercept     5.71      0.27     5.16     6.23 1.00     2758     2370
# Yrs           0.02      0.02    -0.02     0.06 1.00     3810     2744
# Corr          0.61      0.25     0.09     1.09 1.00     3456     2673
# moVer         0.07      0.15    -0.22     0.39 1.00     2522     2503
# 
# Simplex Parameters: 
#           Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
# moVer1[1]     0.52      0.22     0.11     0.90 1.00     3583     2529
# moVer1[2]     0.48      0.22     0.10     0.89 1.00     3583     2529
# 
# Family Specific Parameters: 
#       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
# sigma     0.70      0.09     0.55     0.90 1.00     3360     3057

# Så vad kan vi säga om ovanstående? Avseende modellen som har sekunder som 
# outcome så är endast Corr "significant" på 95% nivån. Dock så visar plottarna
# mycket som ni kan diskutera

summary(M_pass)
# Family: bernoulli 
# Links: mu = logit 
# Formula: Corr ~ 1 + Yrs + mo(Ver) 
# Data: d (Number of observations: 35) 
# Samples: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
# total post-warmup samples = 4000
# 
# Population-Level Effects: 
#           Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
# Intercept    -1.60      0.95    -3.61     0.05 1.00     1737     1536
# Yrs           0.01      0.06    -0.11     0.13 1.00     2629     2286
# moVer         0.62      0.49    -0.28     1.67 1.00     1833     1516
# 
# Simplex Parameters: 
#           Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
# moVer1[1]     0.55      0.22     0.12     0.91 1.00     2720     2360
# moVer1[2]     0.45      0.22     0.09     0.88 1.00     2720     2360

# Avseende modellen som har "Corr" som outcome så är inga parametrar 
# signifikanta men, igen, plottarna ger er mycket att diskutera.