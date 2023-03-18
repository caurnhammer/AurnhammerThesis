mkdir -p Stimuli ERP SPR1 SPR2

## Stimuli

cp ../Stimuli/Design1_Densities.pdf Stimuli/Design1_Densities.pdf

## ERP

cp ../ERP/plots/ERP_Design1_rERP/Observed_Full.pdf ERP/ERP_EEG_full.pdf

cp ../ERP/plots/lmerERP_logCloze_Assocnoun/EEG.pdf ERP/ERP_EEG.pdf

# TODO: TOPOPMAPS

# ERP_res_cloze_logCloze
pdfjam 	../ERP/plots/lmerERP_AC_Cloze/res_Cloze.pdf \
		../ERP/plots/lmerERP_AC_logCloze/res_logCloze.pdf \
		--nup 2x1 --landscape \
		--outfile ERP/ERP_res_cloze_logCloze.pdf \
		--papersize '{13cm,15cm}'

# ERP_res_assocnoun_assocverb
pdfjam	../ERP/plots/lmerERP_CD_AssocNoun/res_Association_Noun.pdf \
		../ERP/plots/lmerERP_CD_AssocVerb/res_Association_Verb.pdf \
		--nup 2x1 --landscape \
		--outfile ERP/ERP_res_assocnoun_assocverb.pdf \
		--papersize '{13cm,15cm}'

# ERP_est_res_logCloze_AssocNoun
pdfjam 	../ERP/plots/lmerERP_logCloze_AssocNoun/est_logClozeAssociation_Noun.pdf \
		../ERP/plots/lmerERP_logCloze_AssocNoun/res_logClozeAssociation_Noun.pdf \
		--nup 2x1 --landscape \
		--outfile ERP/ERP_est_res_logCloze_AssocNoun.pdf \
		--papersize '{13cm,15cm}'

# ERP_coefficients_zvalues
pdfjam 	../ERP/plots/lmerERP_logCloze_AssocNoun/coefficients.pdf \
		../ERP/plots/lmerERP_logCloze_AssocNoun/zvalues.pdf \
		--nup 2x1 --landscape \
		--outfile ERP/ERP_coefficients_zvalues.pdf \
		--papersize '{13cm,15cm}'

# ERP_exploratory
pdfjam 	../ERP/plots/lmerERP_A_logCloze/coefficients.pdf \
		../ERP/plots/lmerERP_A_logCloze/A_estimates.pdf \
		--nup 2x1 --landscape \
		--outfile ERP/ERP_exploratory.pdf \
		--papersize '{13cm,15cm}'

## SPR1

cp ../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_logRT.pdf SPR1/RT_1_logRT.pdf

pdfjam 	../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_est_logClozeAssociation_Noun.pdf \
		../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_res_logClozeAssociation_Noun.pdf \
		--nup 2x1 --landscape \
		--outfile SPR1/RT_1_est_res_logCloze_AssocNoun.pdf \
		--papersize '{8cm,15cm}'

pdfjam 	../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_coefficients.pdf \
		../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_zvalue.pdf \
		--nup 2x1 --landscape \
		--outfile SPR1/RT_1_coefficients_zvalue.pdf \
		--papersize '{8cm,15cm}'

## SPR2

cp ../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_logRT.pdf SPR2/RT_2_logRT.pdf

pdfjam 	../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_est_logClozeAssociation_Noun.pdf \
		../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_res_logClozeAssociation_Noun.pdf \
		--nup 2x1 --landscape \
		--outfile SPR2/RT_2_est_res_logCloze_Assocnoun.pdf \
		--papersize '{8cm,15cm}'

pdfjam  ../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_coefficients.pdf \
		../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_zvalue.pdf \
		--nup 2x1 --landscape \
		--outfile SPR2/RT_2_coefficients_zvalue.pdf \
		--papersize '{8cm,15cm}'

pdfjam	../SPR2/plots/lmerRT_A_logCloze/RT_coefficients.pdf \
		../SPR2/plots/lmerRT_A_logCloze/RT_A_estimate_logRT.pdf \
		--nup 2x1 --landscape \
		--outfile SPR2/RT_2_exploratory.pdf \
		--papersize '{8cm,15cm}'