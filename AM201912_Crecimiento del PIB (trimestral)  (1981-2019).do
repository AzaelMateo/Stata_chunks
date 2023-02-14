
cd "E:\Azael Personal\Documentos\Stata\Ejercicios\PIB"
use "E:\Azael Personal\Documentos\Stata\Ejercicios\PIB\AM_201912_Crecimiento del PIB (trimestral). Base. (1981-2019).dta", clear

label variable pib_varporc "Variación anual acumulada de los valores $2013"
generate date = yq(1980, 4) + _n, after(periodo)
format %tq date
drop periodo
tsset date, quarterly 
graph twoway tsline pib_varporc,
egen nv = seq(), f(1) t(4)
keep if nv == 4
generate año = 1980+_n, after(date)
drop date nv
tempfile base
save `base', replace
use "E:\Azael Personal\Documentos\Stata\Ejercicios\SHCP\AM_201905_Balance presupuestario. Base. (1990-2019).dta", clear
keep año ing gast g_costofin
merge 1:1 año using `base'
drop if _merge != 3
generate balpu = ing-gast
generate balprim = balpu+g_costofin
drop ing gast g_costofin _merge

gen newvar = string(pib_varporc, "%3.2f") + "%"
tsset año, year

graph twoway ///
		bar pib_varporc año if tin(2000,2020), barwidth(.98) || ///
		tsline balpu balprim if tin(2000,2020) || scatter pib_varporc año if tin(2000,2020), ///
		msymbol(i) mlabel(newvar) mlabcolor(black) mlabposition(12) mlabgap(1) mlabsize(*.8) ///
		scheme(uncluttered) ///
		xtitle("") ///
		xscale(r(2000 2020)) ///
		xlabel(2000(1)2020, angle() labsize(*.8)) ///
		ytitle("") ///
		yscale(r(-9 6)) ///
		ylabel(-8(2)6, format(%5.0f)) ///
		title("Crecimiento del PIB real y balance fiscal", margin(b+3) position(12)) ///
		subtitle("2000 - 2020", size(small) margin(b+3 t-3)) ///
		note("Fuente: INEGI; Estadísticas Oportunas de Finanzas Públicas, SHCP / @xzxxlmxtxx", size(small) margin(t+2) position(7)) ///
		legend(on) legend(order(1 "Crecimiento del PIB" 2 "Balance público" 3 "Balance primario") size(*.8) rows(1)) ///
		xsize(9) ysize(5) ///
		name(graphs_fisc, replace)
		
graph export "E:\Azael Personal\Documentos\Stata\Ejercicios\PIB\graphs_fisc.png", width(1024) replace

