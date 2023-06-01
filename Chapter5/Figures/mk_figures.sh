mkdir -p tmp Ch5

## Intro
# Bin_AC_Pz
cp ../ERP/plots/Subtraction/Design1_AC_Midline.pdf Ch5/Bin_AC_Pz_Midline.pdf

## Binning based approach
# Bin_AC_randtrials
cp ../ERP/plots/Subtraction/Design1_randtrials_AC_Pz.pdf Ch5/Bin_AC_randtrials.pdf

# Bin_subtraction_Raw
cp ../ERP/plots/Subtraction/Subtraction_Design1_RawN400.pdf Ch5/Bin_subtraction_Raw.pdf

# Bin_subtraction_minusSegment
cp ../ERP/plots/Subtraction/Subtraction_Design1_N400minusSegment.pdf Ch5/Bin_subtraction_minusSegment.pdf

## Regression based approach
# Reg_coefs_AC
cp ../ERP/plots/rERP_N400Segment_AC/Coefficients_Midline.pdf Ch5/Reg_coefs_AC.pdf

# Reg_estres_AC_Midline
pdfjam -q   ../ERP/plots/rERP_N400Segment_AC/Estimated_InterceptFzN400FzSegment_Midline.pdf \
            ../ERP/plots/rERP_N400Segment_AC/Residual_InterceptFzN400FZSegment_Midline.pdf \
            --nup 2x1 --landscape \
            --outfile Ch5/Reg_estres_AC_Midline.pdf \
            --papersize '{15cm,16.5cm}'

# Reg_isoestres_AC
pdfjam -q   ../ERP/plots/rERP_N400Segment_AC/Estimated_Intercept.pdf           ../ERP/plots/rERP_N400Segment_AC/Residual_Intercept.pdf \
            ../ERP/plots/rERP_N400Segment_AC/Estimated_InterceptFzN400.pdf     ../ERP/plots/rERP_N400Segment_AC/Residual_InterceptFzN400.pdf \
            ../ERP/plots/rERP_N400Segment_AC/Estimated_InterceptFzSegment.pdf  ../ERP/plots/rERP_N400Segment_AC/Residual_InterceptFzSegment.pdf \
            --nup 2x3 --landscape \
            --outfile Ch5/Reg_isoestres_AC.pdf \
            --papersize '{15cm,10cm}'

# Reg_coefs_AC_iso
pdfjam -q   ../ERP/plots/rERP_N400Segment_A/Coefficients_Pz.pdf \
            ../ERP/plots/rERP_N400Segment_C/Coefficients_Pz.pdf \
            --nup 2x1 --landscape \
            --outfile Ch5/Reg_coefs_AC_iso.pdf \
            --papersize '{7.5cm,15cm}'

# Reg_dbc19_Pz
cp ../ERP/plots/Subtraction/ERP_dbc19_Midline.pdf Ch5/Reg_dbc19_Pz.pdf

# Reg_dbc19_analyses
pdfjam -q   ../ERP/plots/rERP_dbc19_N400Segment_A/Coefficients_Pz.pdf \
            ../ERP/plots/rERP_dbc19_N400Segment_B/Coefficients_Pz.pdf \
            ../ERP/plots/rERP_dbc19_N400Segment_C/Coefficients_Pz.pdf \
            --nup 3x1 --landscape \
            --outfile Ch5/Reg_dbc19_analyses.pdf \
            --papersize '{5cm,15cm}'

# Cleanup
rm -r tmp