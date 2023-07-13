********************
version 17.0
********************
/*
/*******************************************************************************
* Name of file:	appendix_a
* Author: Isaac M 

* Purpose: This is the master dofile that calls all individual dofiles necessary to replicate the analysis in Appendix A
*******************************************************************************/
*/


* Table A.2: Survey variables summary statistics
do ".\DoFiles\appendix\a\survey_var_ss.do"

* Table A.3: Compliance Rate
do ".\DoFiles\appendix\a\compliance_rate.do"

* Table A.4: Balance table
do ".\DoFiles\appendix\a\balance_table.do"

* Figure A.1: Variable importance for discrete models
* Figure A.2: Variable importance for continuous models (total compensation)
* Figure A.3: Variable importance for continuous models (duration) 
*The boosting model used for variable importance figures relies on the 'SJ5-3' package (st0087), which should be installed and up-to-date.

net install st0087.pkg
net get st0087.pkg

*It is important to add the file boost32.dll, boost64.dll in the parent directory of the repository.
do ".\DoFiles\appendix\a\variable_importance.do"

* Figure A.4: Covariate distribution comparison : Historical and Phase 1 data
rscript using ".\DoFiles\appendix\a\covariate_comparison.R", rversion(4.2.2)

* Figure A.5: Covariate distribution comparison : Historical data: Ended and not ended cases
rscript using ".\DoFiles\appendix\a\covariate_comparison_hd.R", rversion(4.2.2)

