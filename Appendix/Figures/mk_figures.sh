mkdir -p App tmp

## rERPs as ERP averaging

cp ../plots/ERP_Design1_AC_Intercept_rERP/Waveforms/Coefficients.pdf App/ERP_Coef_Intercept.pdf
	
cp ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Observed.pdf App/ERP_Data_AC.pdf

pdfjam -q	../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Coefficients.pdf \
			../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Estimated_InterceptCondCode.pdf \
			--nup 2x1 --landscape \
			--outfile App/ERP_Coef_Est_CondCode.pdf \
			--papersize '{8cm,15cm}'

## Continuous predictors

pdfjam -q	../plots/ERP_Design1_AC_Cloze_rERP/Waveforms/Coefficients.pdf \
			../plots/ERP_Design1_AC_Cloze_rERP/Waveforms/Estimated_InterceptCloze.pdf \
			../plots/ERP_Design1_AC_cloze_rERP/Waveforms/Residual_InterceptCloze.pdf \
			--nup 3x1 --landscape \
			--outfile App/ERP_Coef_Est_Cloze.pdf \
			--papersize '{5cm,15cm}'

pdfjam -q	../plots/ERP_Design1_AC_Cloze_rERP/Waveforms/Residual_InterceptCloze.pdf \
			../plots/ERP_Design1_AC_logCloze_rERP/Waveforms/Residual_InterceptlogCloze.pdf \
			--nup 2x1 --landscape \
			--outfile App/ERP_Res_Cloze_logCloze.pdf \
			--papersize '{8cm,15cm}'

pdfjam -q	../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Observed.pdf \
			../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Coefficients.pdf \
			--nup 2x1 --landscape \
			--outfile App/ERP_Data_Coef_Full.pdf \
			--papersize '{8cm,15cm}'

pdfjam -q 	../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Estimated_Intercept.pdf                      ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Residual_Intercept.pdf \
			../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Estimated_InterceptAssociation_Noun.pdf      ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Residual_InterceptAssociation_Noun.pdf \
			../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Estimated_InterceptCloze.pdf                 ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Residual_InterceptCloze.pdf \
			../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Estimated_InterceptClozeAssociation_Noun.pdf ../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Residual_InterceptClozeAssociation_Noun.pdf \
			--nup 2x4 --landscape \
			--outfile tmp/ERP_Est_Res_Full.pdf \
			--papersize '{30cm,15cm}'
pdfjam -q	--scale 2 \
			../plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Observed_wavelegend.pdf \
			--landscape \
			--outfile tmp/Observed_wavelegend.pdf \
			--papersize '{1cm,15cm}'
pdfjam -q	tmp/ERP_Est_Res_Full.pdf \
			tmp/Observed_wavelegend.pdf \
			--delta '0 -290' --nup 1x2 --landscape \
			--outfile tmp/ERP_Est_Res_Full_2.pdf \
			--papersize '{32cm,15cm}' 
pdfjam -q	tmp/ERP_Est_Res_Full_2.pdf \
			--landscape \
			--outfile App/ERP_Est_Res_Full.pdf \
			--papersize '{30cm,15cm}' \
			--trim '2cm 10cm 2cm 0cm' 

## lmer

pdfjam -q	../plots/lmerERP_A_logCloze/coefficients.pdf \
			../plots/lmerERP_A_logCloze/A_estimates.pdf \
			--nup 2x1 --landscape \
			--outfile App/ERP_Est_lmer.pdf \
			--papersize '{13cm,15cm}' 

## Inferentials

cp ../plots/ERP_Design1_cloze_Assocnoun_across_rERP/Waveforms/t-values.pdf App/ERP_tval_across.pdf

## Topos

cp ../plots/ERP_Design1_AC_cloze_rERP/Waveforms/Coefficients_Full.pdf App/ERP_Coef_Cloze_Grid.pdf

cp ../plots/ERP_Design1_AC_cloze_rERP/Topos/Observed_C_300-500.pdf App/ERP_Data_AC_Topo.pdf

pdfjam -q	--scale 1.5 ../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Observed_topolegend.pdf \
			--outfile tmp/Observed_topolegend.pdf
pdfjam -q	../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Estimated_InterceptCloze_distractor_B_600-1000.pdf \
			../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Estimated_InterceptPlaus_B_600-1000.pdf \
			../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Estimated_InterceptPlausCloze_distractor_B_600-1000.pdf \
			../plots/ERP_Design2_Plaus_Clozedist_rERP/Topos/Observed_B_600-1000.pdf \
			tmp/Observed_topolegend.pdf \
			--delta '-20 0' --nup 5x1 \
			--landscape \
			--outfile App/ERP_Estimated_Topos_B.pdf \
			--papersize '{8cm,32cm}'

# ## SPR

cp ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Observed.pdf App/RT_Observed.pdf

pdfjam -q	../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Estimated_Intercept.pdf 			    	   ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Residual_Intercept.pdf \
			../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Estimated_InterceptAssociation_Noun.pdf      ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Residual_InterceptAssociation_Noun.pdf \
			../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Estimated_InterceptCloze.pdf 	  			   ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Residual_InterceptCloze.pdf \
			../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Estimated_InterceptClozeAssociation_Noun.pdf ../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Residual_InterceptClozeAssociation_Noun.pdf \
			--nup 2x4 --landscape \
			--outfile tmp/RT_Est_Res_Full.pdf \
			--papersize '{30cm,15cm}'
pdfjam -q	--scale 2 \
			--trim '0 0 1.5cm 0' \
			../plots/SPR2_Design1_Cloze_Assocnoun_rRT/Observed_rtlegend.pdf \
			--landscape \
			--outfile tmp/Observed_rtlegend.pdf \
			--papersize '{1cm,15cm}'
pdfjam -q	tmp/RT_Est_Res_Full.pdf \
			tmp/Observed_rtlegend.pdf \
			--delta '0 -280' --nup 1x2 --landscape \
			--outfile tmp/RT_Est_Res_Full_2.pdf \
			--papersize '{31cm,15cm}'  
pdfjam -q	tmp/RT_Est_Res_Full_2.pdf \
			--landscape \
			--outfile App/RT_Est_Res_Full.pdf \
			--papersize '{29cm,15cm}' \
			--trim '2cm 10cm 2cm 0cm' 

pdfjam -q	../plots/SPR2_Design1_Cloze_Assocnoun_across_rRT/Coefficients.pdf \
			../plots/SPR2_Design1_Cloze_Assocnoun_across_rRT/t-values.pdf \
			--nup 2x1 --landscape \
			--outfile App/RT_tval_across.pdf \
			--papersize '{7.5cm,15cm}'

# Cleanup
rm -r tmp