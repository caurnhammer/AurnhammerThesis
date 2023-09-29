This repository contains the code and data necessary to reproduce the analyses of my PhD thesis (submitted).

# Code

The ```code/``` directory contains experiment-independent code to run and visualize regression analyses following the idea of rERPs. There are implementations of both least-squares regression and linear mixed effects regression and specifications for electroencephalography (EEG) and self-paced reading data.
Regressions are computed in ```julia```, visualisation and multiple comparisons correction are in ```R```.  Unix shell commands and ```pdfjam``` are used to arrange graphs into the final figures.

# Data

The data are provided as a release within this repository and to be placed in the top-level ```data/``` directory.

# Language and package versions

**```julia v1.7.3```**

```CategoricalArrays v0.10.7```
```Combinatorics v1.0.2```
```CSV v0.10.9```
```DataFrames v1.5.0```
```Distributed (standard)```
```Distributions v0.25.86```
```LinearAlgebra (standard)```
```PooledArrays v1.4.2```
```StatsBase v0.33.21```

**```R v4.1.2```**

```data.table v1.14.8```
```ggplot2 v3.4.1```
```grid (base)```
```gridExtra v2.3```

**```zsh v5.9```**

```pdfjam 3.03```
