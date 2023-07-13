clear
set more off

*Install user-written commands (for reproducibility I include the version)

*	rscript
*! rscript 1.1.1 16may2023 by David Molitor and Julian Reif
net install rscript, from("https://raw.githubusercontent.com/reifjulian/rscript/master") replace

*	estout
*! version 3.24  30apr2021  Ben Jann
capture ssc install estout

*	ritest
*! version 1.1.7 feb2020.
capture ssc install ritest

*	distcomp
*! version 0.2 15may2019
capture ssc install distcomp

*User-written comands for the appendix

*	orth_out
*! version 2.9.4 Joe Long 03feb2016
capture ssc install orth_out

*cvlasso
*! cvlasso 1.0.09 28jun2019
*! lassopack package 1.3
*! authors aa/ms
capture ssc install cvlasso 



*Change local path where the project folder is located
cd "C:\Users\isaac\Dropbox\repos\information_settlement"
global directorio "C:\Users\isaac\Dropbox\repos\information_settlement"

*Set significance
global star "star(* 0.1 ** 0.05 *** 0.01)"

*Set scheme
set scheme white_tableau, perm

*# of bootstrap replications - # of permutation tests (in the paper we use 1000 reps)
global reps 100
