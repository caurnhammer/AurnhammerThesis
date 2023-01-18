mkdir final_pdf/

cp ../ERP/plots/Subtraction/ERP_Design1_AC_Pz.pdf final_pdf/ERP_Design1_AC_Pz.pdf

cp ../ERP/plots/Subtraction/ERP_Design1_randtrials_AC_Pz.pdf final_pdf/ERP_Design1_randtrials_Pz.pdf

cp ../ERP/plots/Subtraction/Subtraction_Design1_RawN400_Tertiles.pdf final_pdf/ERP_Subtraction_Raw.pdf
cp ../ERP/plots/Subtraction/Subtraction_Design1_N400minusSegment_Tertiles_AC.pdf final_pdf/ERP_Subtraction_minusSegment.pdf

cp ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Coefficients_Pz.pdf final_pdf/ERP_Coefs_AC.pdf

convert -density 250 ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Estimated_InterceptPzN400PzSegment.pdf ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Residual_InterceptPzN400PzSegment.pdf \
   +append -page 200:100 \
   final_pdf/ERP_estres_AC.pdf

montage -mode concatenate -density 250 \
     ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Estimated_Intercept.pdf ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Residual_Intercept.pdf \
     ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Estimated_InterceptPzN400.pdf ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Residual_InterceptPzN400.pdf \
     ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Estimated_InterceptPzSegment.pdf ../ERP/plots/ERP_Design1_N400Segment_AC/Waveforms/Residual_InterceptPzSegment.pdf \
     -tile 2x3 \
     final_pdf/ERP_isoestres_AC.pdf

cp ../ERP/plots/Subtraction/ERP_dbc19_Pz.pdf final_pdf/ERP_dbc19_Pz.pdf

montage -mode concatenate -density 250 \
    ../ERP/plots/ERP_dbc19_N400Segment_A/Waveforms/Coefficients_Pz.pdf \
    ../ERP/plots/ERP_dbc19_N400Segment_B/Waveforms/Coefficients_Pz.pdf \
    ../ERP/plots/ERP_dbc19_N400Segment_C/Waveforms/Coefficients_Pz.pdf \
    -tile 3x1 \
    final_pdf/ERP_dbc19_analyses.pdf