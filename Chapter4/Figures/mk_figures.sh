## Check if tmp dir exists
mkdir -p tmp  Stimuli SPR ERP

## Stimuli
cp ../Stimuli/Design2_Densities.pdf Stimuli/Design2_Densities.pdf

## SPR
# RT_logRT
cp ../SPR/plots/rRT_Plaus_Clozedist/RT_logRT.pdf  SPR/RT_logRT.pdf

# RT_est_res_PlausClozedist
pdfjam 	../SPR/plots/rRT_Plaus_Clozedist/RT_est_PlausCloze_distractor.pdf \
	   	../SPR/plots/rRT_Plaus_Clozedist/RT_res_PlausCloze_distractor.pdf \
		--nup 2x1 --landscape \
		--outfile tmp/RT_est_res_PlausClozedist.pdf \
		--papersize '{8cm,15cm}'
pdfjam	--scale 1 \
		../SPR/plots/rRT_Plaus_Clozedist/RT_est_1_rtlegend.pdf \
		--landscape \
		--outfile tmp/RT_est_1_rtlegend.pdf \
		--papersize '{1cm,15cm}'
pdfjam 	tmp/RT_est_res_PlausClozedist.pdf \
		tmp/RT_est_1_rtlegend.pdf \
		--delta '0 -80' --nup 1x2 --landscape \
		--outfile tmp/RT_est_res_PlausClozedist_2.pdf \
		--papersize '{9cm,15cm}' 
pdfjam 	tmp/RT_est_res_PlausClozedist_2.pdf \
		--landscape \
		--outfile SPR/RT_est_res_PlausClozedist.pdf \
		--papersize '{9cm,15cm}' \
		--trim '2cm 3.5cm 2cm 1cm' 

# RT_coefficients_zvalue
pdfjam ../SPR/plots/rRT_Plaus_Clozedist/RT_coefficients.pdf \
	   ../SPR/plots/rRT_Plaus_Clozedist/RT_zvalue.pdf \
	   --nup 2x1 --landscape \
	   --outfile SPR/RT_coefficients_zvalue.pdf \
	   --papersize '{8cm,15cm}'

# RT_Precrit_coefficients_zvalue
pdfjam 	../SPR/plots/rRT_PrecritRT_Plaus_Clozedist/RT_coefficients.pdf \
		../SPR/plots/rRT_PrecritRT_Plaus_Clozedist/RT_zvalue.pdf \
		--nup 2x1 --landscape \
	   	--outfile SPR/RT_Precrit_coefficients_zvalue.pdf \
		--papersize '{8cm,15cm}'

## ERP
# ERP_Observed_Full
cp ../ERP/plots/rERP_Plaus_Clozedist/Waveforms/Observed_Full.pdf ERP/ERP_Observed_Full.pdf

# Observed_Topos_B
pdfjam 	--scale 1.5 ../ERP/plots/rERP_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
		--outfile tmp/Observed_topolegend.pdf
pdfjam 	../ERP/plots/rERP_Plaus_Clozedist/Topos/Observed_B_250-400.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Topos/Observed_B_300-500.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Topos/Observed_B_600-1000.pdf \
		tmp/Observed_topolegend.pdf \
		--delta '-20 0' --nup 4x1 --landscape \
		--outfile ERP/ERP_Observed_Topos_B.pdf \
		--papersize '{8cm,24cm}'

# Observed_Topos_C
pdfjam 	../ERP/plots/rERP_Plaus_Clozedist/Topos/Observed_C_250-400.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Topos/Observed_C_300-500.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Topos/Observed_C_600-1000.pdf \
		tmp/Observed_topolegend.pdf \
		--delta '-20 0' --nup 4x1 --landscape \
		--outfile ERP/ERP_Observed_Topos_C.pdf \
		--papersize '{8cm,24cm}'

# ERP_EstRes_Pz
pdfjam  ../ERP/plots/rERP_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlausCloze_distractor.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Waveforms/ResidualPz_InterceptPlausCloze_distractor.pdf \
		--nup 2x1 --landscape \
		--outfile tmp/ERP_EstRes_Pz.pdf \
		--papersize '{8cm,15cm}'
pdfjam 	tmp/ERP_EstRes_Pz.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlausCloze_distractor_wavelegend.pdf \
		--delta '0 -80' --nup 1x2 --landscape \
		--outfile ERP/ERP_EstRes_Pz.pdf \
		--papersize '{9cm,15cm}' \
		--trim '2cm 2.5cm 1cm 0cm'

# ERP_Coef_C3Pz
pdfjam 	../ERP/plots/rERP_Plaus_Clozedist/Waveforms/Coefficients_C3.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Waveforms/Coefficients_Pz.pdf \
		--nup 2x1 --landscape \
		--outfile tmp/ERP_Coef_C3Pz.pdf \
		--papersize '{8cm,15cm}'
pdfjam 	--scale 1.5 \
		../ERP/plots/rERP_Plaus_Clozedist/Waveforms/Coefficients_C3_wavelegend.pdf \
		--landscape \
		--outfile tmp/Coefficients_C3_wavelegend.pdf \
		--papersize '{1cm,15cm}'
pdfjam  tmp/ERP_Coef_C3PZ.pdf \
		tmp/Coefficients_C3_wavelegend.pdf \
		--delta '0 -80' --nup 1x2 --landscape \
		--outfile tmp/ERP_Coef_C3Pz_2.pdf \
		--papersize '{9cm,15cm}' 
pdfjam 	tmp/ERP_Coef_C3Pz_2.pdf \
		--landscape \
		--outfile ERP/ERP_Coef_C3Pz.pdf \
		--papersize '{9cm,15cm}' \
		--trim '2cm 2.5cm 2cm 0cm'

# ERP_Est_Iso_Pz
pdfjam 	../ERP/plots/rERP_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptCloze_distractor.pdf \
	 	../ERP/plots/rERP_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlaus.pdf \
		--nup 2x1 --landscape \
		--outfile tmp/ERP_Est_Iso_Pz.pdf \
		--papersize '{8cm,15cm}'

pdfjam  tmp/ERP_Est_Iso_Pz.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlausCloze_distractor_wavelegend.pdf \
		--delta '0 -80' --nup 1x2 --landscape \
		--outfile ERP/ERP_Est_Iso_Pz.pdf \
		--papersize '{9cm,15cm}' \
		--trim '2cm 2.5cm 1cm 0cm'

# ERP_Estimated_Topos_B
pdfjam 	../ERP/plots/rERP_Plaus_Clozedist/Topos/Estimated_InterceptCloze_distractor_B_600-1000.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Topos/Estimated_InterceptPlaus_B_600-1000.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Topos/Estimated_InterceptPlausCloze_distractor_B_600-1000.pdf \
		../ERP/plots/rERP_Plaus_Clozedist/Topos/Observed_B_600-1000.pdf \
		tmp/Observed_topolegend.pdf \
		--delta '-20 0' --nup 5x1 \
		--landscape \
		--outfile ERP/ERP_Estimated_Topos_B.pdf \
		--papersize '{8cm,32cm}'

# ERP_across_tvalues
cp ../ERP/plots/rERP_Plaus_Clozedist_across/Waveforms/t-values.pdf ERP/ERP_across_tvalues.pdf

# ERP_RT
cp ../ERP/plots/rERP_RT/Waveforms/Coefficients_Pz.pdf ERP/ERP_RT.pdf

## remove tmp
rm -r tmp