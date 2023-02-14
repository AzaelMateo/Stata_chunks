
use "C:\Users\dell\Documents\Stata\Ejercicios\IMSS\Base aseg perm (1997-2020).dta", replace
generate date = ym(1997, 6) + _n, after(fecha)
format %tmMon_CCYY date
tsset date, monthly
drop fecha nombresdemedidas

graph twoway ///
		tsline nacional, ///
		msize(vsmall) ///
		scheme(plotplain) ///
		xtitle("") ///
		tline(2002m8, lwidth(26) lcolor(gs13) lpattern(solid)) ///
			tline(2000m12 2004m4, lcolor(gs8) lpattern(dash)) ///
		tline(2009m7, lwidth(15) lcolor(gs13) lpattern(solid)) ///
			tline(2008m7 2010m7, lcolor(gs8) lpattern(dash)) ///
		tscale(r(1997m7 2020m5)) ///
		tlabel(1998m1(12)2020m4, angle(vertical)) ///
		ytitle("") ///
		yscale(r(9700000 18000000)) ///
		ylabel(9000000(1500000)18000000, format(%10.0fc)) ///
		title("Asegurados asociados a un empleo permanente", size(large) margin(b+3) position(12)) ///
		note("@xzxxlmxtxx / IMSS.", size(medsmall) margin(t+2) position(7)) ///
		xsize(10) ysize(5) ///
		name(graphs_asegperm, replace)


graph twoway ///
		tsline norte if tin(1999m7,2020m4)|| tsline centro if tin(1999m7,2020m4) || tsline occidente if tin(1999m7,2020m4) || tsline sur if tin(1999m7,2020m4), ///
		msize(vsmall) ///
		scheme(plotplain) ///
		xtitle("") ///
		tline(2002m8, lwidth(24) lcolor(gs13) lpattern(solid)) ///
			tline(2000m12 2004m4, lcolor(gs8) lpattern(dash)) ///
		tline(2009m7, lwidth(15) lcolor(gs13) lpattern(solid)) ///
			tline(2008m7 2010m7, lcolor(gs8) lpattern(dash)) ///
		tscale(r(1999m7 2020m5)) ///
		tlabel(2000m1(12)2020m4, angle(vertical)) ///
		ytitle("") ///
		yscale(r(1000000 6000000)) ///
		ylabel(1000000(500000)6000000, format(%10.0fc)) ///
		title("Asegurados asociados a un empleo permanente", size(large) margin(b+3) position(12)) ///
		note("@xzxxlmxtxx / IMSS.", size(medsmall) margin(t+2) position(7)) ///
		xsize(10) ysize(5) ///
		name(graphs_asegperm, replace)



