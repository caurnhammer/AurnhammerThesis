mkdir final_pdf/

cp ../Stimuli/Design1_Densities.pdf final_pdf/
 
cp ../SPR1/plots/logRT.pdf final_pdf/RT_logRT.pdf

convert -density 250 ../SPR1/plots/est_srprcnoun.pdf \
	../SPR1/plots/res_srprcnoun.pdf \
	+append -page 400:200 \
	final_pdf/RT_est_res_srprcnoun.pdf

convert -density 250 ../SPR1/plots/coefficients.pdf \
	../SPR1/plots/zvalue.pdf \
	+append -page 400:200 \
	final_pdf/RT_coefficients_zvalue.pdf
