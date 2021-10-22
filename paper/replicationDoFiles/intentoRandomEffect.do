reg seconcilio i.treatment `controls' if treatment!=0 & phase==1, robust  cluster(fecha)


ritest i.treatment _b[i.treatment], reps(1000) seed(125): reg seconcilio i.treatment i.anio i.junta i.phase i.numActores if treatment!=0 & phase==1, robust  cluster(fecha)


ritest dtreatment _b[dtreatment], reps(1000) seed(125): reg convenio_m5m dtreatment##i.p_actor i.anio i.junta i.phase i.numActores if treatment!=0, robust  cluster(fecha)
