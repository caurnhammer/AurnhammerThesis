mkdir -p Ch6

pdfjam  ../../Chapter3/ERP/plots/ERP_Design1_ABCD_Pz.pdf \
        ../../Chapter3/SPR1/plots/logRT.pdf \
        ../../Chapter3/SPR2/plots/srpnoun/logRT.pdf \
        --nup 3x1 --landscape \
        --outfile Ch6/Design1_Results.pdf \
        --papersize '{8cm,15cm}'

pdfjam  ../../Chapter4/ERP/plots/Design2_Plaus_Clozedist/Waveforms/Observed_Pz.pdf \
        ../../Chapter4/SPR/plots/Design2_Plaus_Clozedist/RT_logRT.pdf \
        --nup 2x1 --landscape \
        --outfile Ch6/Design2_Results.pdf \
        --papersize '{8m,15cm}'

pdfjam  ../../Chapter5/ERP/plots/Subtraction/Subtration_N400minusSegment_Quantiles.pdf \
        ../../Chapter5/ERP/plots/adsbc21_N400Segment_AC/Coefficients_Pz.pdf \
        ../../Chapter5/ERP/plots/adsbc21_N400Segment_AC/Estimated_InterceptPzN400.pdf \
        --nup 3x1 --landscape \
        --outfile Ch6/PO_Results.pdf \
        --papersize '{8m,15cm}'