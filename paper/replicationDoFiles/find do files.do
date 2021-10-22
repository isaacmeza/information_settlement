*ssc install find
*ssc install rcd
 
*******************************************************************************/
clear
set more off
 
 
rcd "./DoFiles"  : find *.do , match(placebo_operation.dta) show
