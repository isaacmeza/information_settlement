

We briefly discuss each of the methods to compute the standard errors above. 

Consider the following model
\[Y = X\beta+ \epsilon\]
where $k$ is the number of regressors including the constant and $n$ the number of observations.

Recall the computation of the robust variance estimator
\[\widehat{\operatorname{Var}} = q_c\widehat{V}\left(\sum_{k=1}^M u_k^{(G)\prime}u_k^{(G)}\right)\widehat{V}\]
where $G_1,\ldots G_M$ are the specified clusters, $u_k^{(G)} = \sum_{j\in G_k} u_j$, with $u_j$  row vectors of scores, $q_c$ is a finite-sample adjustment, and $\widehat{V} = (X^\prime X)^{-1}$ is a conventional variance estimator calculation.


\begin{enumerate}
    \item \textbf{Eicker-Huber-White : } In this case $M=N$, and
    \[u_j = (y_j-x_j\hat{\beta})x_j\;,\quad\quad q_c = \frac{N}{N-k}\]
    This are the usual heteroskedasticity-consistent standard errors associated with the work of \cite{white, eicker, huber}. This are computed through the standard \texttt{robust} option in STATA.
    
    \item \textbf{Random inference : } To assess whether the sample realization of the chosen test statistic, is in line with its distribution under the null hypothesis,  we permute assignment to treatment. 
    
    Let $\widetilde{\beta_{m}}$  be the estimation under the random permutation of treatment. The rank statistics is
    \[\operatorname{rk}^{\text{abs}} = \sum_{m=1}^{M} \mathds{1}[\left|\widetilde{\beta_{m}}\right|\geq \left|\hat{\beta}\right|]\]
  , and we compute the two-sided p-value as
   \[p^{\text{two-sided}} = \frac{1}{M} \operatorname{rk}^{\text{abs}}\]
      We use the command \texttt{ritest} to compute this p-values. However, for column (6) we follow the procedure described in Algorithm \ref{RI}

    \item \textbf{Liang-Zeger : } This are the standard robust variance estimator, due to \cite{liang}. A simple multiplicative adjustments is used : 
    \[u_j = (y_j-x_j\hat{\beta})x_j\;,\quad\quad q_c = \frac{N-1}{N-k}\frac{M}{M-1}\]
    This are computed through the standard \texttt{vce(cluster)} option in STATA.
    
    
    \item \textbf{Davidson-MacKinnon (HC2) : } This method specify  alternative  bias  corrections  for  the  robust  variance  calculation (\cite{davidson}). 
    
   \[u_j = \frac{1}{\sqrt{1-x_j\widehat{V}x_j^\prime}}(y_j-x_j\hat{\beta})x_j\;,\quad\quad q_c = 1\]
    This method tends to produce slightly more conservative confidence intervals, and is unbiased under homoskedasticity. The option in STATA is given by \texttt{vce(hc2)}.
    
    \item \textbf{Davidson-MacKinnon (HC3) : } In this case
    
   \[u_j = \frac{1}{1-x_j\widehat{V}x_j^\prime}(y_j-x_j\hat{\beta})x_j\;,\quad\quad q_c = 1\]
    This method is better under heteroskedasticity and produces confidence intervals that tend to be even more conservative (\cite{davidson}).  The option in STATA is given by \texttt{vce(hc3)}.
    
     \item \textbf{Jacknife : } This is a resampling method  which leaves an individual cluster out of the computation of the statistics, in this case $\hat{beta}$. Let $\hat{\beta}_{(j)}$ be the estimation for this statistics when leaving out the $j$-th cluster. Define $\widehat{\beta_{j^*}} = \widehat{\beta_{(j)}}+M \left(\widehat{\beta}-\widehat{\beta_{(j)}}\right)$, the variance is then computed as 
     \[\widehat{\operatorname{Var}} = \frac{1}{M(M-1)} \sum_{j=1}^{M}(\widehat{\beta}_{j^*}-\bar{\beta^*})^2\; ,\quad\quad \bar{\beta^*} = \frac{1}{N} \sum_{j=1}^{M} \widehat{\beta_{j^*}}\]
    
    We use the option \texttt{vce(jackknife, cluster( ))} to compute this standard errors.
    
     \item \textbf{Bootstrap : } This is another resampling method where the random sampling is done with replacement. Define $\widehat{\beta_{i}}$ to be the statistic from the $i$-th bootstrap sample. The variance is estimated as
     \[\widehat{\operatorname{Var}} = \frac{1}{k-1} \sum_{i=1}^{k}(\widehat{\beta_{i}}-\bar{\beta})^2\; ,\quad\quad \bar{\beta} = \frac{1}{k} \sum_{j=1}^{M} \widehat{\beta_{i}}\]
     
    We use the option \texttt{vce(bootstrap, cluster( ))} for the computation of this standard errors.
    
     \item \textbf{Bootstrap BCa : } To overcome the overcoverage issues in percentile bootstrap CIs, the BCa method corrects for both bias and skewness of the bootstrap parameter estimates by incorporating a bias-correction factor and an acceleration factor (\cite{efron1994introduction}).
     
Following the notation as in the previous method. Let $z_0 = \Phi^{-1} \{\#(\widehat{\beta_{(i)}}-\widehat{\beta_{}})/k\}$. Define the jackknife estimate of acceleration as $a = \frac{\sum_{i=1}^n(\bar\beta_{(\cdot)}-\widehat{\beta_{i}})^3}{6\{\sum_{i=1}^n(\bar\beta_{(\cdot)}-\widehat{\beta_{(i)}})^2\}^{3/2}}$, where $\widehat{\beta_{(i)}}$ are the leave-one-out (jackknife) estimates of $\widehat{\beta_{\cdot}}$, and $\bar\beta_{(\cdot)}$ their mean. Let
\begin{align*}
    p_1 =& \Phi\left\lbrace z_0+\frac{z_0-z_{1-\alpha/2}}{1-a(z_0-z_{1-\alpha/2})} \right\rbrace \\
    p_2 =& \Phi\left\lbrace z_0+\frac{z_0+z_{1-\alpha/2}}{1-a(z_0+z_{1-\alpha/2})} \right\rbrace
\end{align*}
    
    where $z_{1-\alpha/2}$is the $1-\alpha/2$th quantile of the normal distribution. The bias-corrected and accelerated method yields confidence intervals
    \[[\beta_{p_1}^*,\beta_{p_2}^*]\]
with $\beta_{p}^*$ the p-th quantile of the bootstrap distribution.

    We use the option \texttt{vce(bootstrap, cluster( ) bca)} for the computation of this standard errors.
    
     
    \item \textbf{Bell-McCaffery : } The bias-reduction modification developed by \cite{} is analogous to the HC2 bias reduction.     
    
\end{enumerate}
