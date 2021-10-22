clear
set more off

if "`c(username)'" == "shagg"{
global sharelatex D:\MCLC\Pilot 1\information_sett\Replication
global scaleup D:\MCLC\Pilot 1\information_sett\Replication\scaleup
global pilot3Complete "D:\MCLC\Pilot3"
global pilot3 D:\MCLC\Pilot 1\information_sett\Replication\p1_w_p3
global paper D:\MCLC\Pilot 1\information_sett\Replication
}
else{
global sharelatex E:\MCLC\Pilot 1\information_sett\Replication
global scaleup E:\MCLC\Pilot 1\information_sett\Replication\scaleup
global pilot3Complete "E:\MCLC\Pilot3"
global pilot3 E:\MCLC\Pilot 1\information_sett\Replication\p1_w_p3
global paper E:\MCLC\Pilot 1\information_sett\Replication
}

qui do "$sharelatex\DoFiles\tabnumlab.do"
