mkdir final_pdf/

cp ../ERP/plots/Subtraction/ERP_Design1_AC_Cz.pdf final_pdf/

cp ../ERP/plots/Subtraction/Subtration_RawN400_Quantiles.pdf final_pdf/ERP_Subtraction_Raw.pdf
cp ../ERP/plots/Subtraction/Subtration_N400minusSegment_Quantiles.pdf final_pdf/ERP_Subtraction_minusSegment.pdf

cp ../ERP/plots/ERP_Design1_N400Segment/Waveforms/Coefficients_Cz.pdf final_pdf/ERP_Interdependence_Coefs.pdf

montage -mode concatenate -density 60 \
	../ERP/plots/GAT/GAT_coef_intercept.pdf \
    ../ERP/plots/GAT/GAT_coef_timestep.pdf ../ERP/plots/GAT/GAT_coef_segment.pdf \
	-tile 2x2 \
    final_pdf/GAT_Design1_C_coefs.pdf
