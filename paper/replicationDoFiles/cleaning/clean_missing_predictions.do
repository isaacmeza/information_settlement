/*
Import missing predictions 
*/

import delimited ".\DB\missingPredictionsP1.csv", varn(1) clear

destring junta prediccionmontolaudopos prediccionproblaudoneg prediccionproblaudopos, force replace

gen liq_total_laudo_avgM = prediccionproblaudopos*prediccionmontolaudopos

save ".\DB\missingPredictionsP1", replace

bysort junta exp anio: drop if _n>1

save ".\DB\missingPredictionsP1_wod", replace
