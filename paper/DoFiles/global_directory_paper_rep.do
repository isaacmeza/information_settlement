clear
set more off

global sharelatex "C:\Users\isaac\Dropbox\ReplicationFinal"
global scaleup "C:\Users\isaac\Dropbox\ReplicationFinal\scaleup"
global pilot3 "C:\Users\isaac\Dropbox\ReplicationFinal\p1_w_p3"
global paper "C:\Users\isaac\Dropbox\ReplicationFinal"

cd "C:\Users\isaac\Dropbox\ReplicationFinal"
global directorio "C:\Users\isaac\Dropbox\ReplicationFinal"

global star "star(* 0.1 ** 0.05 *** 0.01)"
qui do "$sharelatex\DoFiles\tabnumlab.do"
