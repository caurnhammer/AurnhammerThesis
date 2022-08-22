mkdir final_pdf/

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Waveforms/Observed.pdf \
	final_pdf/ERP_Observed.pdf

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Waveforms/EstimatedPz_InterceptPlausCloze_distractor.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/ResidualPz_InterceptPlausCloze_distractor.pdf \
	+append -page 400:200 \
	final_pdf/ERP_EstRes_Pz.pdf

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Waveforms/Coefficients_C3.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Waveforms/Coefficients_Pz.pdf \
	+append -page 400:200 \
	final_pdf/ERP_Coef_C3Pz.pdf

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_250-400.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_300-500.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_600-1000.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 400:130 \
	final_pdf/ERP_Observed_Topos_B.pdf

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_C_250-400.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_C_300-500.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_C_600-1000.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 400:130 \
	final_pdf/ERP_Observed_Topos_C.pdf

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Topos/Estimated_InterceptCloze_distractor_B_600-1000.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Estimated_InterceptPlaus_B_600-1000.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Estimated_InterceptPlausCloze_distractor_B_600-1000.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_600-1000.pdf \
	../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 350:80 \
	final_pdf/ERP_Estimated_Topos_B.pdf

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist_across/Waveforms/t-values.pdf \
	final_pdf/ERP_across_tvalues.pdf

