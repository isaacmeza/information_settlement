Notes regarding final replication.

# Cleaning

### 1.a- Pilot
_cleaning_pilot_rep.do_ - Main cleaning do file for pilot data and its surveys. Runs _name_cleaning_pilot_rep.do_ for name cleaning.

### 1.b- Scaleup

_cleaning_scaleup.do_ - Main cleanin do file for scaleup, surveys, and 2018 followup. Runs _name_cleaning_scaleup.do_ for name cleaning.
### 1.c- Historical data
_cleaning_hd_rep.do_ - Main cleaning do file for hd. Runs _name_cleaning_hd_rep.do_ for name cleaning.

### 1.d- Time preferences
_mxfls_cleaning.do_ appends and cleans answers to MxFLS data.

_DB_time_pref.do_ Constructs a comparable database of frequencies of answers between MxFLS survey and P1 surveys.

### 1.e-P1 & P2 Followups
_importAppend2020Followups.do_ Imports and cleans outcome data for both P1 and P2

_cleaning_missingCasefiles.do_ Cleans initial casefilings that were recovered during 2019 - 2020

_clean_missing_predictions.do_ cleans calculator predictions that were originally missing

_cleanTerminaciones_v2.do_ cleans P1 & P2 2020 followups

### 1.f- Pilot 3
_cleanPilot3.do_ cleans P3 database for followup

_CleaningP3.do_ cleans survey (2m & 2w) data, as well as treatment data. It runs several auxiliay do files:  _cleaning_2m_survey.do_, _cleaning_2w_survey.do_

### 1.g- ITT sample for P1 & P2
_ITTSample.do_ selects casefiles that entered the ITT sample for the calculator experimental arm.

# Main Results
## Tables
### T1: Pilots description
_pilotsDescription.do_ Gets data for P1 & P2. May consider redoing the do file / table to include P3. Igual para incluir fechas etc.

### T2: Summary statistics
_SS_replicates.do_ Somehow the table got lost and this one does not replicate the one in the overleaf (we have more obs) I'll check the rest of the results to make sure this table is correct.

### T3: main regression
_ITTVersion.do_ This creates P1 & P2 columns except for CF
_treatment_effects_IV_CF_noConciliator_rep_NoDuplicatesITT.do_ Performs the CF regression under different assumptions (presented also in A.C)
_p3ResultMainTable.do_ Performs the regression with P3 outcomes

These results get merged in the excel file _TreatmentEffectsOnSettlement_main.xlsx_

### T4: TE by lawyer type
_teByLawyer.do_ Performs separate regressions for private and public lawyers. Result is formated in the te_bylawyer.xlsx file.

### T5 Expectation updating

_te_p3_updating.do_ Does the regression. Still misssing a xlsx to provide format.

### T6: Outcomes by treatments
_endMode.do_ Creates the table in a preformated xlsx

### T7: Recovery at 42 months (1 & 2)
_welfare42monthsP1P2.do_ Slight changes in the results.

### T8: Welfare effects P3
_P3welfare.do_ Missing an excel table that formats this.

## Figures

### F1: Claimed vs compensation
_Fig1_amount_plots_rep.R_ (ahorita la checo)

### F2: Time duration HD
_caseending_overtime_rep.do_

### F3: Knowledge of the law and lawsuit
_knowledge_allByType.do_

### F4: Treatment format
No do file

### F5: Calculator prediction for settled casefiles
_calculatorDistributionForSettled.do_

### F6: Calculator distribution for cases that won in court
_caseValueKdensitiesdo.do_ does it. It also does it disaggregated by phase.

# Appendix A
## Tables
### A1: Casefile variables Description
No do file
histograms_npv_hd.do <- quien sabe qué es esto

### A2: Survey SS For P1.
_surveyP1SS.do_

### A3: Experiment integrity
_complianceTable.do_ does panel A using only P1 data
_ComplianceP2Tables.do_ does panel B using only P2 data
_showUp.do_ does panel C using P1 & P2 data

### A4: Balance table
_balance.do_ Me faltan observaciones del P1. Supongo que vienen de las neuvas iniciales? Está raro

### A5: Fit assessment of the calculators (discrete)
calc_predictions.R (NO SE HA CORRIDO)

### A6: Fit assessment of the calculators (continoous)
calc_predictions.R (NO SE HA CORRIDO)

## Figures
### FA1: Covariate distribution comparison HS vs P1
_covariate_plots.R_ and _covariate_plots_hd.R_
### FA3: Covariate distribution comparison HS vs P2
v_covariate_plots.R_ and _covariate_plots_hd.R_


# Appendix C
## Tables
### TC.1 .- Amount asked (log), amount won (log), and probability of winning - Historic Data
_reg_amount.do_ Output gets aggregated in the _TableReg1_log.xlsx_ file.

### TC.2.-  Balance of casefiles having negative recovery amount.
_negReturnHD.do_. Output gets written in _negative_returners_balance.xlsx_

### TC.3.- Balance regression on characteristics conditional on employee present
_ep_balance.do_. Output gets formatted in _ep_balance.xlsx_

### TC.4.- Employee presence
_pEmployeePresence.do_.

### TC.5.- Expectations Relative to Prediction
_prediction_cases_pooled_MergeWithPilotOperation.do_ does Panel A w/P1 & P2
_ExpectationsFromP3forPrediction_cases_pooles_panelB.do_ does Panel B with P3
Results are merged and formatted in table _prediction_cases_pooled.xlsx_

### TC.6.- First stage and robustness for the control function regression
_treatment\_effects\_IV\_CF.do_. Problem with column 1, gotta get back to it.

### TC.7.- Heterogeneity in treatment effects
_te_heterogeneity.do_ produces raw output, _te_heterogeneity.xlsx_ formats it.

### TC.8.- Treatment Effects with placebo arm - Phase 1
_tePlacebos.do_

### TC.9.- Updating - Phase 1
_update_reg_theta_rel_uc.do_ performs the regression with underconfidents, while _update_reg_theta_rel_oc.do_ does it for over confidents. The table is actually composed of 2 different tables, both of which exist in the excel workbook _update_reg_theta_rel.xlsx_.

### TC.10 - Duration of Cases by Treatment
_welfare42monthsP1P2.do_ does, among other things, this regression. _duration.xlsx_ adds format to the results.


## Figures
### F1.C.- Stylized Depiction of the Labor Justice Process

### F2.C.-Calculator Treatment Format (example) - Phase 2

### F3.C.- Calculator Treatment Format (example) - Phase 3

### F4.C.- Distribution of Amount Collected, by Type of Lawyer
_cdf_value_claims.do_ does both subgraphs and appends them

### F5.C.-
_oc_comparison_B.do_ does 6 subfigures, they get appended directly on latex.

### F6.C.- Settlement Amount vs.  Calculator
_ratioGananciaConvenio.do_

### F7.C.- Outcomes when Plaintiff was Present, by Treatment
_welfare42monthsp1p2.do_ does the 2 subfigures, latex compiled them as one


### F8.C.- Calculator Predictions for Plaintiff Court Judgment, By Phase
caseValueKdensitiesdo.do

##Figures
