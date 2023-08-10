clear
set more off


*Change local path where the project folder is located
cd "C:/Users/isaac/Dropbox/repos/information_settlement"
global directorio "C:/Users/isaac/Dropbox/repos/information_settlement"

*Set significance
global star "star(* 0.1 ** 0.05 *** 0.01)"

*Set scheme
set scheme white_tableau, perm

*# of bootstrap replications - # of permutation tests (in the paper we use 1000 reps)
global reps 100

*Set seed
set seed 9435