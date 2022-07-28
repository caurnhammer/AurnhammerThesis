cp ../plots/ERP_Design1_AC_Intercept_rERP/Waveforms/Coefficients.pdf final_pdf/ERP_Coef_Intercept.pdf
	
cp ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Observed.pdf final_pdf/ERP_AC.pdf

convert -density 500 ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Coefficients.pdf ../plots/ERP_Design1_AC_CondCode_rERP/Waveforms/Estimated_InterceptCondCode.pdf \
	+append -page 500:250 \
	final_pdf/ERP_CondCode.pdf
