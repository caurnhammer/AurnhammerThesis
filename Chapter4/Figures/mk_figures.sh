mkdir final_pdf/

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Waveforms/Observed.pdf \
	final_pdf/ERP_Observed.pdf

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_250-400.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_B_600-1000.pdf ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 300:130 \
	final_pdf/ERP_Observed_Topos_B.pdf

convert -density 500 ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_C_250-400.pdf \
    ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_C_600-1000.pdf ../ERP/plots/Design2_Plaus_Clozedist/Topos/Observed_topolegend.pdf \
	+append -page 300:130 \
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

