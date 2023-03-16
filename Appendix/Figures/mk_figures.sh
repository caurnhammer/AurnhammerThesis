mkdir -p App

cp ../plots/ERP_Design1_AC_Intercept_rERP/Waveforms/Coefficients.pdf App/ERP_Coef_Intercept.pdf
	
cp ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Observed.pdf App/ERP_Data_AC.pdf

convert -density 1000 \
	../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Coefficients.pdf ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Estimated_InterceptCondCode.pdf \
	+append -page 500:250 \
	App/ERP_Coef_Est_CondCode.pdf

convert -density 1000 \
	../plots/ERP_Design1_AC_Cloze_rERP/Waveforms/Coefficients.pdf ../plots/ERP_Design1_AC_Cloze_rERP/Waveforms/Estimated_InterceptCloze.pdf ../plots/ERP_Design1_AC_cloze_rERP/Waveforms/Residual_InterceptCloze.pdf \
	+append -page 600:200 \
	App/ERP_Coef_Est_Cloze.pdf

convert -density 1000 \
	../plots/ERP_Design1_AC_Cloze_rERP/Waveforms/Residual_InterceptCloze.pdf ../plots/ERP_Design1_AC_logCloze_rERP/Waveforms/Residual_InterceptlogCloze.pdf \
	+append -page 400:200 \
	App/ERP_Res_Cloze_logCloze.pdf

convert -density 1000 \
	../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Observed.pdf ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Coefficients.pdf \
	+append -page 500:250 \
	App/ERP_Data_Coef_Full.pdf

montage -mode concatenate -density 1000 \
	../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Estimated_Intercept.pdf                      ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Residual_Intercept.pdf \
	../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Estimated_InterceptAssociation_Noun.pdf      ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Residual_InterceptAssociation_Noun.pdf \
	../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Estimated_InterceptCloze.pdf                 ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Residual_InterceptCloze.pdf \
    ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Estimated_InterceptClozeAssociation_Noun.pdf ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Residual_InterceptClozeAssociation_Noun.pdf \
	-tile 2x4 \
	App/ERP_Est_Res_Full.pdf

convert -density 1000 \
	../plots/lmerERP_A_logCloze/coefficients.pdf ../plots/lmerERP_A_logCloze/A_estimates.pdf \
	+append -page 500:450 \
	App/ERP_Est_lmer.pdf
	
cp ../plots/ERP_Design1_cloze_Assocnoun_across_rERP/Waveforms/t-values.pdf App/ERP_tval_across.pdf

cp ../plots/ERP_Design1_AC_cloze_rERP/Waveforms/Coefficients_Full.pdf App/ERP_Coef_Cloze_Grid.pdf

cp ../plots/ERP_Design1_AC_cloze_rERP/Topos/Observed_C_300-500.pdf App/ERP_Data_AC_Topo.pdf

convert -density 1000 \
	../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Estimated_InterceptCloze_distractor_B_600-1000.pdf \
    ../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Estimated_InterceptPlaus_B_600-1000.pdf \
	../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Estimated_InterceptPlausCloze_distractor_B_600-1000.pdf \
    ../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Observed_B_600-1000.pdf \
	../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Observed_topolegend.pdf \
	+append -page 350:80 \
	App/ERP_Estimated_Topos_B.pdf

cp ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Observed.pdf App/RT_Observed.pdf

montage -mode concatenate -density 1000 \
	../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Estimated_Intercept.pdf 			    	   ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Residual_Intercept.pdf \
	../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Estimated_InterceptAssociation_Noun.pdf      ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Residual_InterceptAssociation_Noun.pdf \
	../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Estimated_InterceptCloze.pdf 	  			   ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Residual_InterceptCloze.pdf \
    ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Estimated_InterceptClozeAssociation_Noun.pdf ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Residual_InterceptClozeAssociation_Noun.pdf \
	-tile 2x4 \
	App/RT_Est_Res_Full.pdf

convert -density 1000 ../plots/SPR2_Design1_Cloze_Assocnoun_across_rRT/Coefficients.pdf ../plots/SPR2_Design1_Cloze_Assocnoun_across_rRT/t-values.pdf \
	+append -page 500:250 \
	App/RT_tval_across.pdf