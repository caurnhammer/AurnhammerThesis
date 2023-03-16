mkdir -p ERP SPR1 SPR2

## ERP

cp ../ERP/plots/ERP_Design1_rERP/Observed_Full.pdf ERP/ERP_EEG_full.pdf

cp ../ERP/plots/lmerERP_logCloze_Assocnoun/EEG.pdf ERP/ERP_EEG.pdf

# TODO: TOPOPMAPS

convert -density 250 \
	../ERP/plots/lmerERP_AC_Cloze/res_Cloze.pdf \
	../ERP/plots/lmerERP_AC_logCloze/res_logCloze.pdf \
	+append -page 500:450 \
	ERP/ERP_res_cloze_logCloze.pdf

convert -density 250 \
	../ERP/plots/lmerERP_CD_AssocNoun/res_Association_Noun.pdf \
	../ERP/plots/lmerERP_CD_AssocVerb/res_Association_Verb.pdf \
	+append -page 500:450 \
	ERP/ERP_res_assocnoun_assocverb.pdf

convert -density 250 \
	../ERP/plots/lmerERP_logCloze_AssocNoun/est_logClozeAssociation_Noun.pdf \
	../ERP/plots/lmerERP_logCloze_AssocNoun/res_logClozeAssociation_Noun.pdf \
	+append -page 500:450 \
	ERP/ERP_est_res_logCloze_AssocNoun.pdf

convert -density 250 \
	../ERP/plots/lmerERP_logCloze_AssocNoun/coefficients.pdf \
	../ERP/plots/lmerERP_logCloze_AssocNoun/zvalues.pdf \
	+append -page 500:450 \
	ERP/ERP_coefficients_zvalues.pdf

convert -density 250 \
	../ERP/plots/lmerERP_A_logCloze/coefficients.pdf \
	../ERP/plots/lmerERP_A_logCloze/A_estimates.pdf \
	+append -page 500:450 \
	ERP/ERP_exploratory.pdf

## SPR1

cp ../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_logRT.pdf SPR1/RT_1_logRT.pdf

convert -density 250 \
	../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_est_logClozeAssociation_Noun.pdf \
	../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_res_logClozeAssociation_Noun.pdf \
	+append -page 500:250 \
	SPR1/RT_1_est_res_logCloze_AssocNoun.pdf

convert -density 250 \
	../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_coefficients.pdf \
	../SPR1/plots/lmerRT_logCloze_AssocNoun/RT_zvalue.pdf \
	+append -page 500:250 \
	SPR1/RT_1_coefficients_zvalue.pdf

## SPR2

cp ../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_logRT.pdf SPR2/RT_2_logRT.pdf

convert -density 250 \
	../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_est_logClozeAssociation_Noun.pdf \
	../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_res_logClozeAssociation_Noun.pdf \
	+append -page 500:250 \
	SPR2/RT_2_est_res_logCloze_Assocnoun.pdf

convert -density 250 \
	../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_coefficients.pdf \
	../SPR2/plots/lmerRT_logCloze_AssocNoun/RT_zvalue.pdf \
	+append -page 500:250 \
	SPR2/RT_2_coefficients_zvalue.pdf

convert -density 250 \
	../SPR2/plots/lmerRT_A_logCloze/RT_coefficients.pdf \
	../SPR2/plots/lmerRT_A_logCloze/RT_A_estimate_logRT.pdf \
	+append -page 500:250 \
	SPR2/RT_2_exploratory.pdf