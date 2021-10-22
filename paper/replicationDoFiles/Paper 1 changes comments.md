# Paper 1 changes comments

## Table A.3 

### Panel (a)
There was a mistake with the data displayed on the "any" cell of the compliance with exit survey. The problem was solved. 

### Panel (b)
There were doubts regarding why we don't have data for the control group's compliance with the baseline survey. However, it seems as if no survey was administered for this population. Recall that the control variables come from the initial casefilings, so this has no implication for the regressions or balance tables. 

## Table A.4 
### reg T vs all X, report Pval del f test de que todas las betas son cero
Added the joint significance tests aside the number of observations. Joint significance tests are significant for P2 and for pooled data. 

## Balance table for the placebo
We have not encoded the initial casefilings of the placebo sample, so no balance can be done. These are the variables that we do have, which have to do with how the audiencia was held: 

v1            num_lista     anio          entrega_ra    p_actor       p_rdemandado  pago_conve~o  capturista~o  count_partes
fecha_lista   horario_au~a  notificacion  entrega_dem   p_ractor      se_concilio   se_desistio   count_plac~o  partes
dia_semana    expediente    entrega_ac~r  entrega_rd    p_demandado   cantidad_c~o  cantidad_d~o  placebo

## Balance table for hearing time

Done. Can't do the same balance table for non-pooled data due to lack of variation. However the results in the paper are presented for pooled data only, so we should be fine. 

There is one choice to make: obviously firm and firm lawyer presence is not balanced, but this is not what is being instrumented. If we do not include these variables, everything is perfectly balanced. 

## Run an IV instead of the CF
