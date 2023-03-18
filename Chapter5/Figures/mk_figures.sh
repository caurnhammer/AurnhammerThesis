mkdir -p tmp Ch5

## Intro
# Bin_AC_Pz
cp ../ERP/plots/Subtraction/Design1_AC_Pz.pdf Ch5/Bin_AC_Pz.pdf.pdf

## Binning based approach
# Bin_AC_randtrials
cp ../ERP/plots/Subtraction/Design1_randtrials_AC_Pz.pdf Ch5/Bin_AC_randtrials.pdf

# Bin_subtraction_Raw
cp ../ERP/plots/Subtraction/Subtraction_Design1_RawN400.pdf Ch5/Bin_subtraction_Raw.pdf

# Bin_subtraction_minusSegment
cp ../ERP/plots/Subtraction/Subtraction_Design1_N400minusSegment.pdf Ch5/Bin_subtraction_minusSegment.pdf

## Regression based approach
# Reg_coefs_AC
cp ../ERP/plots/rERP_N400Segment_AC/Coefficients_Pz.pdf Ch5/Reg_coefs_AC.pdf

# Reg_estres_AC
pdfjam -q   ../ERP/plots/rERP_N400Segment_AC/Estimated_InterceptPzN400PzSegment.pdf \
            ../ERP/plots/rERP_N400Segment_AC/Residual_InterceptPzN400PzSegment.pdf \
            --nup 2x1 --landscape \
            --outfile tmp/Reg_estres_AC.pdf \
            --papersize '{7.5cm,15cm}'
pdfjam -q   --scale 2 \
            ../ERP/plots/rERP_N400Segment_AC/Observed_wavelegend.pdf \
            --landscape \
            --outfile tmp/Observed_wavelegend.pdf \
            --papersize '{1cm,15cm}'
pdfjam -q   tmp/Reg_estres_AC.pdf \
            tmp/Observed_wavelegend.pdf \
            --nup 1x2 --delta '0 -70' --landscape \
            --outfile tmp/Reg_estres_AC_2.pdf \
            --papersize '{8cm,15cm}'
pdfjam -q   tmp/Reg_estres_AC_2.pdf \
            --landscape \
            --outfile Ch5/Reg_estres_AC.pdf \
            --papersize '{8cm,15cm}' \
            --trim '2cm 2.5cm 2cm 0cm'

# Reg_isoestres_AC
pdfjam -q   ../ERP/plots/rERP_N400Segment_AC/Estimated_Intercept.pdf          ../ERP/plots/rERP_N400Segment_AC/Residual_Intercept.pdf \
            ../ERP/plots/rERP_N400Segment_AC/Estimated_InterceptPzN400.pdf    ../ERP/plots/rERP_N400Segment_AC/Residual_InterceptPzN400.pdf \
            ../ERP/plots/rERP_N400Segment_AC/Estimated_InterceptPzSegment.pdf ../ERP/plots/rERP_N400Segment_AC/Residual_InterceptPzSegment.pdf \
            --nup 2x3 --landscape \
            --outfile tmp/Reg_isoestres_AC.pdf \
            --papersize '{22.5cm,15cm}'
pdfjam -q   tmp/Reg_isoestres_AC.pdf \
            tmp/Observed_wavelegend.pdf \
            --nup 1x2 --delta '0 -200' --landscape \
            --outfile tmp/Reg_isoestres_AC.pdf \
            --papersize '{23.5cm,15cm}'
pdfjam -q   tmp/Reg_isoestres_AC.pdf \
            --nup 1x2 --delta '0 -200' --landscape \
            --outfile Ch5/Reg_isoestres_AC.pdf \
            --papersize '{23.5cm,15cm}' \
            --trim '2.3cm 13cm 2.3cm 0cm'

# Reg_coefs_AC_iso
pdfjam -q   ../ERP/plots/rERP_N400Segment_A/Coefficients_Pz.pdf \
            ../ERP/plots/rERP_N400Segment_C/Coefficients_Pz.pdf \
            --nup 2x1 --landscape \
            --outfile tmp/Reg_coefs_AC_iso.pdf \
            --papersize '{7.5cm,15cm}'        
pdfjam -q   --scale 2 \
            ../ERP/plots/rERP_N400Segment_AC/Coefficients_Pz_wavelegend.pdf \
            --landscape \
            --outfile tmp/Coefficients_Pz_wavelegend.pdf \
            --papersize '{1cm,15cm}'
pdfjam -q   tmp/Reg_coefs_AC_iso.pdf \
            tmp/Coefficients_Pz_wavelegend.pdf \
            --nup 1x2 --delta '0 -70' --landscape \
            --outfile tmp/Reg_coefs_AC_iso_2.pdf \
            --papersize '{8.5cm,15cm}' 
pdfjam -q   tmp/Reg_coefs_AC_iso_2.pdf \
            --landscape \
            --outfile Ch5/Reg_coefs_AC_iso.pdf \
            --papersize '{8.5cm,15cm}' \
            --trim '2cm 2cm 2cm 0cm'

# Reg_dbc19_Pz
cp ../ERP/plots/Subtraction/dbc19_Pz.pdf Ch5/Reg_dbc19_Pz.pdf

# Reg_dbc19_analyses
pdfjam -q   ../ERP/plots/rERP_dbc19_N400Segment_A/Coefficients_Pz.pdf \
            ../ERP/plots/rERP_dbc19_N400Segment_B/Coefficients_Pz.pdf \
            ../ERP/plots/rERP_dbc19_N400Segment_C/Coefficients_Pz.pdf \
            --nup 3x1 --landscape \
            --outfile tmp/Reg_dbc19_analyses.pdf \
            --papersize '{5cm,15cm}' 
pdfjam -q   tmp/Reg_dbc19_analyses.pdf \
            tmp/Coefficients_Pz_wavelegend.pdf \
            --nup 1x2 --delta '0 -50' --landscape \
            --outfile tmp/Reg_dbc19_analyses_2.pdf \
            --papersize '{6cm,15cm}' 
pdfjam -q   tmp/Reg_dbc19_analyses_2.pdf \
            --landscape \
            --outfile Ch5/Reg_dbc19_analyses.pdf \
            --papersize '{6cm,15cm}' \
            --trim '1.5cm 1.5cm 1.5cm 0cm'

# Cleanup
rm -r tmp