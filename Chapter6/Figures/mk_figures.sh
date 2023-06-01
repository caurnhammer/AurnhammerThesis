mkdir -p tmp Ch6

# Design 1
pdfjam -q   ../../Appendix/plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Observed.pdf \
            ../../Chapter3/SPR1/plots/lmerRT_logCloze_AssocNoun/RT_logRT_nolegend.pdf \
            ../../Chapter3/SPR2/plots/lmerRT_logCloze_AssocNoun/RT_logRT_nolegend.pdf \
            --nup 3x1 --landscape \
            --outfile tmp/Design1_Results.pdf \
            --papersize '{5cm,15cm}'
pdfjam -q   --scale 1.5 \
            ../../Appendix/plots/ERP_Design1_Cloze_Assocnoun_rERP/Waveforms/Observed_wavelegend.pdf \
            --landscape \
            --outfile tmp/Observed_wavelegend.pdf \
            --papersize '{1cm,15cm}'
pdfjam -q   tmp/Design1_Results.pdf \
            tmp/Observed_wavelegend.pdf \
            --nup 1x2 --delta '0 -40' --landscape \
            --outfile tmp/Design1_Results_2.pdf \
            --papersize '{6cm,15cm}'
pdfjam -q   tmp/Design1_Results_2.pdf \
            --landscape \
            --outfile Ch6/Design1_Results.pdf \
            --papersize '{6cm,15cm}' \
            --trim '1.75cm 1.75cm 1.75cm 0cm'

# Design 2
pdfjam -q   ../../Chapter4/ERP/plots/rERP_Plaus_Clozedist/Waveforms/Observed_Pz.pdf \
            ../../Chapter4/SPR/plots/rRT_PrecritRT_Plaus_Clozedist/RT_logRT.pdf \
            --nup 2x1 --landscape \
            --outfile tmp/Design2_Results.pdf \
            --papersize '{7.5cm,15cm}'
pdfjam -q   --scale 1.5 \
            ../../Chapter4/ERP/plots/rERP_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlausCloze_distractor_wavelegend.pdf \
            --landscape \
            --outfile tmp/Observed_wavelegend.pdf \
            --papersize '{1cm,15cm}'
pdfjam -q   tmp/Design2_Results.pdf \
            tmp/Observed_wavelegend.pdf \
            --nup 1x2 --delta '0 -70' --landscape \
            --outfile tmp/Design2_Results_2.pdf \
            --papersize '{8.5cm,15cm}'
pdfjam -q   tmp/Design2_Results_2.pdf \
            --landscape \
            --outfile Ch6/Design2_Results.pdf \
            --papersize '{8.5cm,15cm}' \
            --trim '2cm 2.5cm 2cm 0cm'

# Single-trial dynamics
pdfjam -q   ../../Chapter5/ERP/plots/Subtraction/Subtraction_Design1_N400minusSegment.pdf \
            ../../Chapter5/ERP/plots/rERP_N400Segment_AC/Coefficients_Pz.pdf \
            ../../Chapter5/ERP/plots/rERP_N400Segment_AC/Estimated_InterceptFzN400_withlegend.pdf \
            --nup 3x1 --landscape \
            --outfile Ch6/SingleTrial_Results.pdf \
            --papersize '{5cm,15cm}'

# Cleanup
rm -r tmp