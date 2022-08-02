cp ../plots/ERP_Design1_AC_Intercept_rERP/Waveforms/Coefficients.pdf final_pdf/ERP_Coef_Intercept.pdf
	
cp ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Observed.pdf final_pdf/ERP_Data_AC.pdf

convert -density 500 ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Coefficients.pdf ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Estimated_InterceptCondCode.pdf \
	+append -page 500:250 \
	final_pdf/ERP_Coef_Est_CondCode.pdf

convert -density 500 ../plots/ERP_Design1_AC_cloze_rERP/Waveforms/Coefficients.pdf ../plots/ERP_Design1_AC_cloze_rERP/Waveforms/Estimated_InterceptCloze.pdf ../plots/ERP_Design1_AC_cloze_rERP/Waveforms/Residual_InterceptCloze.pdf \
	+append -page 600:200 \
	final_pdf/ERP_Coef_Est_Cloze.pdf

convert -density 500 ../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Observed.pdf ../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Coefficients.pdf \
	+append -page 500:250 \
	final_pdf/ERP_Data_Coef_Full.pdf

montage -mode concatenate -density 500 \
	../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Estimated_Intercept.pdf ../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Residual_Intercept.pdf \
	../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Estimated_Interceptrcnoun.pdf ../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Residual_Interceptrcnoun.pdf \
	../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Estimated_InterceptCloze.pdf ../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Residual_InterceptCloze.pdf \
    ../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Estimated_InterceptClozercnoun.pdf ../plots/ERP_Design1_cloze_rcnoun_rERP/Waveforms/Residual_InterceptClozercnoun.pdf \
	-tile 2x4 \
	final_pdf/ERP_Est_Res_Full.pdf

cp ../plots/ERP_Design1_AC_cloze_rERP/Waveforms/Coefficients_Full.pdf final_pdf/ERP_Coef_Cloze_Grid.pdf

cp ../plots/ERP_Design1_AC_cloze_rERP/Topos/Observed_C_300-500.pdf final_pdf/ERP_Data_AC_Topo.pdf

convert -density 500 ../plots/ERP_Design2_Plaus_Clozedist/Topos/Estimated_InterceptCloze_distractor_B_600-1000.pdf \
    ../plots/ERP_Design2_Plaus_Clozedist/Topos/Estimated_InterceptPlaus_B_600-1000.pdf \
	../plots/ERP_Design2_Plaus_Clozedist/Topos/Estimated_InterceptPlausCloze_distractor_B_600-1000.pdf \
    ../plots/ERP_Design2_Plaus_Clozedist/Topos/Observed_B_600-1000.pdf \
	../plots/ERP_Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 350:80 \
	final_pdf/ERP_Estimated_Topos_B.pdf
