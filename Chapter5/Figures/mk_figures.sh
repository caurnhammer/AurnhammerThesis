cp ../ERP/plots/Subtraction/adsbc21_AC_Pz.pdf final_pdf/adsbc21_AC_Pz.pdf

cp ../ERP/plots/Subtraction/adsbc21_randtrials_AC_Pz.pdf final_pdf/adsbc21_AC_randtrials.pdf

cp ../ERP/plots/Subtraction/Subtraction_adsbc21_RawN400_Tertiles.pdf final_pdf/adsbc21_subtraction_Raw.pdf
cp ../ERP/plots/Subtraction/Subtraction_adsbc21_N400minusSegment_Tertiles_AC.pdf final_pdf/adsbc21_subtraction_minusSegment.pdf

cp ../ERP/plots/adsbc21_N400Segment_AC/Coefficients_Pz.pdf final_pdf/adsbc21_coefs_AC.pdf

convert -density 250 ../ERP/plots/adsbc21_N400Segment_AC/Estimated_InterceptPzN400PzSegment.pdf ../ERP/plots/adsbc21_N400Segment_AC/Residual_InterceptPzN400PzSegment.pdf \
   +append -page 200:100 \
   final_pdf/adsbc21_estres_AC.pdf

montage -mode concatenate -density 250 \
     ../ERP/plots/adsbc21_N400Segment_AC/Estimated_Intercept.pdf ../ERP/plots/adsbc21_N400Segment_AC/Residual_Intercept.pdf \
     ../ERP/plots/adsbc21_N400Segment_AC/Estimated_InterceptPzN400.pdf ../ERP/plots/adsbc21_N400Segment_AC/Residual_InterceptPzN400.pdf \
     ../ERP/plots/adsbc21_N400Segment_AC/Estimated_InterceptPzSegment.pdf ../ERP/plots/adsbc21_N400Segment_AC/Residual_InterceptPzSegment.pdf \
     -tile 2x3 \
     final_pdf/adsbc21_isoestres_AC.pdf

convert -density 250 ../ERP/plots/adsbc21_N400Segment_A/Coefficients_Pz.pdf ../ERP/plots/adsbc21_N400Segment_C/Coefficients_Pz.pdf \
   +append -page 200:100 \
   final_pdf/adsbc21_coefs_AC_iso.pdf

cp ../ERP/plots/Subtraction/dbc19_Pz.pdf final_pdf/dbc19_Pz.pdf

montage -mode concatenate -density 250 \
    ../ERP/plots/dbc19_N400Segment_A/Coefficients_Pz.pdf \
    ../ERP/plots/dbc19_N400Segment_B/Coefficients_Pz.pdf \
    ../ERP/plots/dbc19_N400Segment_C/Coefficients_Pz.pdf \
    -tile 3x1 \
   final_pdf/dbc19_analyses.pdf