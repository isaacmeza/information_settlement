# Replication Analysis README

This repository contains the necessary files to replicate the analysis conducted in "Information and Bargaining through Agents: Experimental Evidence from Mexico's Labor Courts". The analysis includes generating tables, figures, and running specific dofiles using datasets provided in the 'DB' subfolder.

This repository is (also) hosted in https://github.com/isaacmeza/information_settlement  

## Folder Structure

The main folder consists of the following subfolders:

- **Tables**: This folder contains the output tables generated during the analysis. Each table is labeled appropriately for easy reference.

- **Figures**: The 'Figures' folder contains the visualizations and graphs generated during the analysis. The figures are saved in TIFF format.

- **_aux**: The '_aux' folder contains auxiliary files that support the analysis. These files may include intermediate outputs, temporary files, or other resources used during the analysis process.

- **DB**: The 'DB' folder contains the datasets necessary for the analysis. These datasets are labeled and organized according to their respective sources or categories. Please refer to the individual dataset files for details on their structure and content. Each dataset has variables properly labeled to explain its meaning, as well as values labeled when neccesary (as in categorical data). This serves also as its own dictionaries. We anonimized the identifiers to preserve data anonimity.
	
Data for main analysis consists on 5 different datasets

1. scaleup_hd.dta : This is a dataset of 5005 historical casefiles used for the construction of the calculator for casefile prediction. 

2. phase_1.dta : Dataset of the first wave of the experiment. 

3. Append Encuesta Inicial Actor.dta : Employee's survey dataset after treatment in the first wave of the experiment.

4. phase_2.dta : Dataset of the second wave of the experiment. 

5. phase_3.dta : Dataset of the third wave of the experiment.


Whereas the data for the analysis in the appendix also includes
		
6. Append Encuesta Inicial Demandado.dta : Firm's survey dataset after treatment in the first wave of the experiment.
		
7. Append Encuesta Inicial Representante Actor.dta : Employee's Lawyer survey dataset after treatment in the first wave of the experiment.
		
8. Append Encuesta Inicial Representante Demandado.dta : Firm's Lawyer survey dataset after treatment in the first wave of the experiment.
		
9. Append Encuesta de Salida : Exit survey after exposure to treatment. 
		
10. hh09w_b3b.dta : Weights for the MxFLS ENNVIH-3 (2009-2012) ; retrieved from http://www.ennvih-mxfls.org/english/weights3.html (7/12/2023)
		
11. iiib_pr : Preferences module for the MxFLS ENNVIH-3 (2009-2012) - Individual databases / Book IIIB ; retrieved from http://www.ennvih-mxfls.org/english/ennhiv-3.html (7/12/2023)



- **Dofiles**: The 'Dofiles' folder contains the main files used for analysis. These dofiles, mostly written in STATA, except one which is written in R, include the instructions and code necessary to reproduce the results presented in the research paper. 

	The files for the appendix are located in the subfolder appendix. Two further subfolders are found, for analysis in Appendix A and Appendix C respectively. 


## Replication Instructions

To replicate the analysis, follow these steps:

1. Clone or download the entire repository to your local machine. 

2. Ensure you have the required software and dependencies installed to run the dofiles and process the datasets. 

3. Change the path in 'global_directory_paper.do' & in the Rscript 'difference_claims_compensation.R', indicating where the local repository is located. 

	3.1 Run the file 'global_directory_paper.do' 
	3.2 Run the file 'master.do', which calls all the individual files to replicate individual tables & figures. These files are typically named descriptively to indicate their purpose or the analysis step they perform.
	The dofiles may generate intermediate files, which will be saved in their respective folders.

Comments or instructions within the dofiles may guide you through the particular analysis. We also refer to the paper to further explanation on the analysis performed. 

4. Once the analysis is complete, you can find the output tables in the 'Tables' folder and the figures in the 'Figures' folder. Compare these outputs with the results reported in the research paper to verify the replication.

5. For the analysis in the appendix the following must need to be executed.
	
	5.1 Run the file 'appendix_a.do', which call all the individual files to replicate individual tables & figures in Appendix A. 

	Note : The "calculator" model is constructed in R, where the comparison of different ML models is executed. The files are located inside the Github repository https://github.com/isaacmeza/information_settlement/tree/master/calculator

	5.2 Run the file 'appendix_c.do', which call all the individual files to replicate individual tables & figures in Appendix C. 


Please note that replication may require substantial computational resources or specific software versions.


## Reporting Issues and Support

If you encounter any issues during the replication process or have questions related to the analysis, please don't hesitate to report them. You can reach out to the original authors of the research paper for assistance and support. Feel free to use the provided contact information in the research paper or reach out through the GitHub repository's issue tracker. The authors are committed to addressing reported issues and providing necessary support to ensure a successful replication experience.




--------------------------------------------------------------------