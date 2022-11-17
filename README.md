# US_GAMM_visualization_polar
This repository provides two customized functions which can be used to visualize ultrasound tongue contours fitted using *GAMM (Generalized Additive Mixed Models)*.
The contours are displayed in the polar coordinate system by using the `scatterpolar` plot type provided by `plotly`.

For a quick demo, first we import the example data:

``` r
df_gamm = read.csv("data_gamm_example.csv")
head(df_gamm)
```

```
  Subject Point     Theta       R V1 V2 V1.V2
1      S1     1 0.6428341 67.0793  i NR  i.NR
2      S1     1 0.6428341 54.5902  a NR  a.NR
3      S1     1 0.6428341 55.2726  i  R   i.R
4      S1     1 0.6428341 55.9623  u  R   u.R
5      S1     1 0.6428341 55.8445  a  R   a.R
6      S1     1 0.6428341 51.6170  u  R   u.R
```

Regarding our example data, each individual tongue contour consists of 42 data points.
The coulmn `Theta` and `R` represent the angular (**rad**) and the radial (**mm**) coordinate respectively.
`V1` and `V2` are categorical variables, and `V1.V2` indicates the interaction between them.

We then fit a simple GAMM model using `bam()` from the package `mgcv`:

``` r
library(mgcv)

cols = c("Subject", "V1", "V2", "V1.V2")
df_gamm[cols] = lapply(df_gamm[cols], factor)

gamm.model = bam(R ~ V1.V2 +
                 s(Theta, bs="cr", k=10) +
                 s(Theta, bs="cr", k=10, by=V1.V2) +
                 s(Theta, Subject, bs="fs", k=10, m=1, by=V1),
               data=df_gamm, discrete=TRUE)

summary(gamm.model)
```

```
Family: gaussian 
Link function: identity 

Formula:
R ~ V1.V2 + s(Theta, bs = "cr", k = 10) + s(Theta, bs = "cr", 
    k = 10, by = V1.V2) + s(Theta, Subject, bs = "fs", 
    k = 10, m = 1, by = V1)

Parametric coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 57.78775    2.65257  21.786   <2e-16 ***
V1.V2a.R     1.00951    0.06848  14.743   <2e-16 ***
V1.V2e.NR    0.23623    3.83072   0.062    0.951    
V1.V2e.R     0.63526    3.83073   0.166    0.868    
V1.V2i.NR   -0.52626    3.83562  -0.137    0.891    
V1.V2i.R    -0.28005    3.83562  -0.073    0.942    
V1.V2o.NR   -0.27973    3.93970  -0.071    0.943    
V1.V2o.R    -0.14944    3.93977  -0.038    0.970    
V1.V2u.NR    0.71485    3.82624   0.187    0.852    
V1.V2u.R     1.42654    3.82626   0.373    0.709    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Approximate significance of smooth terms:
                        edf Ref.df       F p-value    
s(Theta)              7.342  7.511  50.210  <2e-16 ***
s(Theta):V1.V2a.NR    7.853  8.618  39.268  <2e-16 ***
s(Theta):V1.V2a.R     1.001  1.001   1.071  0.3007    
s(Theta):V1.V2e.NR    8.708  8.962 107.222  <2e-16 ***
s(Theta):V1.V2e.R     1.001  1.001   1.275  0.2589    
s(Theta):V1.V2i.NR    8.227  8.798  52.590  <2e-16 ***
s(Theta):V1.V2i.R     1.001  1.002   3.078  0.0793 .  
s(Theta):V1.V2o.NR    8.586  8.925  96.186  <2e-16 ***
s(Theta):V1.V2o.R     1.001  1.001   1.571  0.2099    
s(Theta):V1.V2u.NR    8.491  8.907 114.562  <2e-16 ***
s(Theta):V1.V2u.R     1.001  1.002   4.123  0.0422 *  
s(Theta,Subject):V1a 92.898 99.000 619.902  <2e-16 ***
s(Theta,Subject):V1e 91.495 99.000 608.968  <2e-16 ***
s(Theta,Subject):V1i 91.790 99.000 352.313  <2e-16 ***
s(Theta,Subject):V1o 83.285 89.000 342.464  <2e-16 ***
s(Theta,Subject):V1u 93.150 99.000 626.317  <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Rank: 608/609
R-sq.(adj) =  0.892   Deviance explained = 89.3%
fREML = 1.1866e+05  Scale est. = 12.925    n = 43554
```

To be able to use the customized plotting functions, pre-install the following packages: `itsadug`, `magrittr`, `plotly`, and `stringr`.
For example, if we want to visualize the contour for the category "a.R", we simply do:

``` r
library(itsadug)
library(magrittr)
library(plotly)
library(stringr)

plot_GAMM_polar(model=gamm.model, target="V1.V2", var1="a.R", title="a.R")
```
![output1]()

If we want to compare the difference between two contours, then specify the other category in `var2`:

``` r
plot_GAMM_polar(model=gamm.model, target="V1.V2", var1="a.R", var2="a.NR", title="a.R & a.NR")
```
![output2]()

As shown in the image above, when two categories were specified, the shaded regions indicate the areas where two contours have significant differences.

On the other hand, if we were to show multiple contours (more than 3), use `plot_GAMM_polar_multi()` and specify the categories at the last:

``` r
plot_GAMM_polar_multi(model=gamm.model, target="V1.V2", title="a.R & i.R & u.R", "a.R", "i.R", "u.R")
```
![output3]()

If no category was specified, the function will show all contours:

``` r
plot_GAMM_polar_multi(model=gamm.model, target="V1.V2", title="V1.V2")
```
![output4]()
