# Check if tmp dir exists
mkdir -p tmp Stimuli SPR ERP

## Stimuli
cp ../Stimuli/adbc23_Densities.pdf Stimuli_Densities.pdf

## SPR
# convert -density 500 \
# 		../rRTs_Plaus_Clozedist/RT_logRT.pdf \
# 		../rRTs_Plaus_Clozedist/RT_logRT_wavelegend.pdf \
# 		-append \
# 		RT_logRT.pdf

# convert -density 500 \
# 		../rRTs_Plaus_Clozedist/RT_est_PlausCloze_distractor.pdf \
# 		../rRTs_Plaus_Clozedist/RT_res_PlausCloze_distractor.pdf \
# 		+append -page 1800x900 \
# 		tmp/RT_est_res_PlausClozedist.pdf

# convert	-density 2000 \
# 	tmp/RT_est_res_PlausClozedist.pdf \
# 	../rRTs_Plaus_Clozedist/RT_logRT_wavelegend.pdf \
# 	-append -page 400x250 \
# 	RT_est_res_PlausClozedist.pdf

# convert	-density 1000 \
# 	../rRTs_Plaus_Clozedist/RT_coefficients.pdf \
# 	../rRTs_Plaus_Clozedist/RT_zvalue.pdf \
# 	+append -page 400x200 \
# 	RT_coefficients_zvalue.pdf

# convert	-density 1000 \
# 	../rRTs_PrecritRT_Plaus_Clozedist/RT_coefficients.pdf \
# 	../rRTs_PrecritRT_Plaus_Clozedist/RT_zvalue.pdf \
# 	+append -page 400x200 \
# 	RT_Precrit_coefficients_zvalue.pdf

## ERP
cp ../ERP/plots/Design2_Plaus_Clozedist/Waveforms/Observed_Full.pdf 	ERP/ERP_Observed_Full.pdf
cp ../ERP/plots/Design2_Plaus_Clozedist_across/Waveforms/t-values.pdf 	ERP/ERP_across_tvalues.pdf
cp ../ERP/plots/Design2_ReadingTime/Waveforms/Coefficients_Pz.pdf 		ERP/ERP_RT.pdf

convert -density 500 \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlausCloze_distractor.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/ResidualPz_InterceptPlausCloze_distractor.pdf \
	+append -page 1680:840 \
	tmp/ERP_EstRes_Pz.pdf
convert -density 2000 \
	tmp/ERP_EstRes_Pz.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlausCloze_distractor_wavelegend.pdf \
	-append -page 800:500 \
	ERP/ERP_EstRes_Pz.pdf

convert -density 500 \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/Coefficients_C3.pdf  \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/Coefficients_Pz.pdf \
	+append -page 1680:840 \
	ERP/tmp/ERP_Coef_C3Pz.pdf
convert -density 2000 \
	tmp/ERP_Coef_C3Pz.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/Coefficients_C3_wavelegend.pdf \
	-append -page 800:500 \
	ERP/ERP_Coef_C3Pz.pdf

convert -density 500 \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptCloze_distractor.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlaus.pdf \
	+append -page 1680:840 \
	tmp/ERP_Est_Iso_Pz.pdf
convert -density 2000 \
	tmp/ERP_Est_Iso_Pz.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlausCloze_distractor_wavelegend.pdf \
	-append -page 800:500 \
	ERP/ERP_Est_Iso_Pz.pdf

convert -density 250 ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_250-400.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_300-500.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_600-1000.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 400:130 \
	ERP/ERP_Observed_Topos_B.pdf

convert -density 250 ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_C_250-400.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_C_300-500.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_C_600-1000.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 400:130 \
	ERP/ERP_Observed_Topos_C.pdf

convert -density 250 ../ERP/plots/Design2_Plaus_Clozedist/Topos/Estimated_InterceptCloze_distractor_B_600-1000.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Estimated_InterceptPlaus_B_600-1000.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Estimated_InterceptPlausCloze_distractor_B_600-1000.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_600-1000.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 350:80 \
	ERP/ERP_Estimated_Topos_B.pdf

# clean up
rm -r tmp