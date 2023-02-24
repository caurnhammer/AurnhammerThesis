convert -density 250 ../../Chapter3/ERP/plots/ERP_Design1_ABCD_Pz.pdf \
    ../../Chapter3/SPR1/plots/logRT.pdf \
    ../../Chapter3/SPR2/plots/srpnoun/logRT.pdf \
    +append -page 600:200 \
    final_pdf/Design1_Results.pdf

convert -density 250 ../../Chapter4/ERP/plots/Design2_Plaus_Clozedist/Waveforms/Observed_Pz.pdf \
    ../../Chapter4/SPR/plots/Design2_Plaus_Clozedist/RT_logRT.pdf \
    +append -page 400:200 \
    final_pdf/Design2_Results.pdf

convert -density 250 ../../Chapter5/ERP/plots/adsbc21_N400Segment_AC/Coefficients_Pz.pdf \
    ../../Chapter5/ERP/plots/adsbc21_N400Segment_AC/Estimated_InterceptPzN400.pdf \
    +append -page 400:200 \
    final_pdf/PO_Results.pdf