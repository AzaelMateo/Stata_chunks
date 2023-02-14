
use "C:\Users\dell\Documents\Stata\Ejercicios\stata-graph-examples-master\Base var int (2001-2019).dta", clear
set scheme uncluttered
local graphs_var = ""
label define months 1 "Ene" 2 "Feb" 3 "Mar" 4 "Abr" 5 "May" ///
	6 "Jun" 7 "Jul" 8 "Ago" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dic"
label values month months
levelsof year, local(years)

/* Loop through all years */
foreach yr of local years{

/* Graph var separately, making sure that y axis range is the same
	for all graphs. I specify these ranges manually here, as well as the
	placement of the year. */
graph twoway `graphs_var' ///
	(line var month if year==`yr', lcolor(`"24 105 109"')), ///
		yscale(r(1 6.2)) ///
		ylabel(2(1)6) ///
		xtitle("") ///
		xscale(r(1 12)) ///
		ytitle("") ///
		yline(4 2, lpattern(dash) lstyle(foreground) lwidth(vthin)) ///
		xlabel(1(1)12, valuelabels) ///
		plotregion(margin(zero)) ///
		text(5 10 `"`yr'"', size(large)) ///
		name(inflation`yr', replace) ///
		subtitle(`"Tasa de inflación anual"', justification(left) margin(b+5 t-1) bexpand) ///
		nodraw
		
/* Add all previous lines to each graph, at 30% opacity. */
local graphs_var = `"`graphs_var'"' + `" (line var month if year==`yr', lcolor(`"24 105 109%10"'))"'

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
	graph combine inflation`yr', ///
	note(`"Fuente: INEGI. @xzxxlmxtxx"') ///
	xsize(10) ysize(5) iscale(*1.3) ///
	name(graphs_var_`yr', replace)

	graph export `"C:\Users\dell\Documents\Stata\Ejercicios\stata-graph-examples-master\graphs_var_`yr'.png"', width(1024) replace
graph drop _all
}


