
use "C:\Users\dell\Documents\Stata\Ejercicios\stata-graph-examples-master\Base empleos por sm (2008-2019).dta", replace
format %10.0fc hasta3sm
format %9.0fc mas3sm
generate date = yq(2007, 4) + _n, before(hasta3sm)
format %tq date
tsset date, quarterly 

preserve
generate hasta3smLag = L1.hasta3sm, after(hasta3sm)
format %10.0g hasta3smLag
generate hasta3smVar = D1.hasta3sm, after(hasta3smLag)
format %10.0g hasta3smVar

generate mas3smLag = L1.mas3sm, after(mas3sm)
format %10.0g mas3smLag
generate mas3smVar = D1.mas3sm, after(mas3smLag)
format %10.0g mas3smVar
restore 

generate hasta3smbase = 17731147, after(hasta3sm)
format %10.0fc hasta3smbase
generate varfromhasta3smbase = hasta3sm - hasta3smbase, after(hasta3smbase)
format %10.0fc varfromhasta3smbase
label variable varfromhasta3smbase "Hasta 3 salarios mínimos"

generate mas3smbase = 9794818, after(mas3sm)
format %10.0fc mas3smbase
generate varfrommas3smbase = mas3sm - mas3smbase, after(mas3smbase)
format %10.0fc varfrommas3smbase
label variable varfrommas3smbase "Más de 3 salarios mínimos"


graph twoway ///
		tsline varfromhasta3smbase varfrommas3smbase if tin(2008q4,2019q3), /// 
		msize(vsmall) ///
		scheme(plotplain) ///
		xtitle("") ///
		tscale(r(2008q3 2019q3)) ///
		tlabel(2008q4(1)2019q3, angle(vertical)) ///
		ytitle("") ///
		yscale(r(-5200000 10200000)) ///
		ylabel(-5200000(2000000)10200000, format(%13.0fc)) ///
		title("Creación y destrucción de empleo asalariado desde el inicio de la crisis", margin(b+3) position(12)) ///
		subtitle("Variación respecto al tercer trimestre de 2008", size(small) margin(b+3 t-3)) ///
		note("Fuente: ENOE, INEGI. @xzxxlmxtxx", size(vsmall) margin(t+2) position(7)) ///
		xsize(12) ysize(6) ///
		name(graphs_creacdestr, replace)
graph export "C:\Users\dell\Documents\Stata\Ejercicios\stata-graph-examples-master\graphs_creacdestr.png", width(1024) replace
