mkdir final_pdf/

cp ../ERP/plots/Subtraction/ERP_Design1_AC_Pz.pdf final_pdf/

cp ../ERP/plots/Subtraction/ERP_Design1_randtrials_C_Pz.pdf final_pdf/ERP_Design1_randtrials_C_Pz.pdf

cp ../ERP/plots/Subtraction/Subtraction_Design1_RawN400_Tertiles.pdf final_pdf/ERP_Subtraction_Raw.pdf
cp ../ERP/plots/Subtraction/Subtraction_Design1_N400minusSegment_Tertiles_C.pdf final_pdf/ERP_Subtraction_minusSegment.pdf

cp ../ERP/plots/ERP_Design1_N400Segment_C/Waveforms/Coefficients_Pz.pdf final_pdf/ERP_Coefs_C.pdf

convert -density 250 ../ERP/plots/Subtraction/Subtraction_Design1_N400minusSegment_Quartiles_A.pdf \
   ../ERP/plots/ERP_Design1_N400Segment_A/Waveforms/Coefficients_Pz.pdf \
   +append -page 200:100 \
   final_pdf/ERP_Baseline.pdf

cp ../ERP/plots/Subtraction/ERP_dbc19_Pz.pdf final_pdf/ERP_dbc19_Pz.pdf

montage -mode concatenate -density 250 \
    ../ERP/plots/Subtraction/Subtraction_dbc19_N400minusSegment_Quantiles_Baseline.pdf ../ERP/plots/ERP_dbc19_N400Segment_A/Waveforms/Coefficients_Pz.pdf \
    ../ERP/plots/Subtraction/Subtraction_dbc19_N400minusSegment_Quantiles_Event-related.pdf ../ERP/plots/ERP_dbc19_N400Segment_B/Waveforms/Coefficients_Pz.pdf \
    ../ERP/plots/Subtraction/Subtraction_dbc19_N400minusSegment_Quantiles_Event-unrelated.pdf ../ERP/plots/ERP_dbc19_N400Segment_C/Waveforms/Coefficients_Pz.pdf \
    -tile 2x3 \
    final_pdf/ERP_dbc19_analyses.pdf