This repository contains the code and data necessary to reproduce the analyses of my PhD thesis.

# Code

The ```code/``` directory contains experiment-independent code to run and visualize regression analyses following the idea of rERPs. There are implementations of both least-squares regression and linear mixed effects regression and specifications for electroencephalography (EEG) and self-paced reading data.
Regressions are computed in ```julia```, visualisation and multiple comparisons correction are in ```R```. ImageMagick shell commands are used to combine graphs into the final figures.

# Data

The data are provided as a release within this repository and to be placed in the top-level ```data/``` directory.

# Language and package versions

**```julia v1.7.3```**

```DataFrames v1.3.4```
```Combinatorics v1.0.2```
```CSV v0.10.4```
```Distributions v0.25.62```
```StatsBase v0.33.17```
```LinearAlgebra (standard)```
```CategoricalArrays v0.10.6```

**```R v4.1.2```**

```data.table v1.14.2```
```ggplot2 v3.3.5```
```gridExtra v2.3```

**```zsh v5.8```**

```ImagemMagick v7.1.0-62```
