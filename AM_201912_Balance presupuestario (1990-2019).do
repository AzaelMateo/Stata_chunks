
*****************************************************************************
version 15
clear all
set more off
gl output = "E:\Azael Personal\Documentos\Stata\Ejercicios\SHCP"
gl data = "E:\Azael Personal\Documentos\Stata\Ejercicios\SHCP"
gl shapes = "C:\Users\dell\Documents\Stata\Ejercicios\mapeodedatos"
cls
/*****************************************************************************************************************************************
 
Nombre archivo: 		AM_201905_Balance presupuestario. Base. (1990-2019)
Autor:          		Azael Mateo		
Máqina:        			Azael Mateo Personal                          				   				                         				   											
Fecha creación          4/Diciembre/2019                                         			   	   		   	                                         			  	
Modificaciones:		    29/Enero/2021
Archivos usados:     
	- Estadísticas Oportunas de las Finanzas Públicas (SHCP) "$data\AM_201905_Balance presupuestario. Base. (1990-2019).dta"
	- STB-23, 
Archivos creados:  
	- AM_201905_Balance presupuestario. Base. (1990-2018).do"
Propósito:
	- Este archivo busca replicar algunos de los cálculos y gráficos del paper "Restos de política fiscal para el desarrollo (Moreno Brid et al, 2019).

********************************************************************************************************************************************/


************************************
/**PRIMERA PARTE: PREPARAMOS BASE**/
************************************

*1.1. Cargamos la base que ocuparemos de la ENIGH2018.
use "$data\AM_201905_Balance presupuestario. Base. (1990-2019).dta", clear

*1.2. Preparamos las variables de interés.
label variable ing "Ingresos presupuestarios (% del PIB)"
label variable i_petroleros "Ingresos petroleros"
label variable i_tribnopet "Ingresos tributarios no petroleros"
label variable i_notribnopet "Ingresos no tributarios no petroleros"
label variable i_orgcontryempprodedo "Ingresos de organismos de control presupuestario directo y empresas productivas del edo"
label variable i_imss "Ingresos del IMSS"
label variable i_issste "Ingresos del ISSSTE"
label variable i_cfe "Ingresos de CFE"
label variable gast "Gasto público neto pagado (% del PIB)"
label variable g_corriente "Gasto corriente presupuestario"
label variable g_capital "Gasto de capital presupuestario"
label variable g_costofin "Costo financiero presupuestario"
label variable g_particip "Participaciones"
label variable g_pensyjub "Pensiones y jubilaciones"
label variable g_corrsinpens "Gasto corriente presupuestario sin pensiones ni jubilaciones"
tsset año, yearly


*****************************
/**SEGUNDA PARTE: GRÁFICOS**/
*****************************

*2.1. Balance Presupuestario.
graph twoway ///
		tsline ing gast if tin(2000,2020), /// 
		clwidth(thick thick) ///
		recast(connected) msymbol(i i) mlabel(ing gast) mlabtextstyle( ) mlabposition(6 12) mlabgap(3 4) mlabsize(*.8 *.8) ///
		scheme(uncluttered) ///
		xtitle("") ///
		tscale(r(1999.5 2022)) ///
		tlabel(2000(1)2020, angle() labsize(*.8)) ///
		ytitle("Porcentaje del PIB", angle(v) size(*.8)) ///
		yscale(r(16 28)) ///
		ylabel(16(2)28, format(%5.0f)) ///
		text(23.1 2020.1 "Ingresos", size(medium) color("24 105 109") place(e)) ///
		text(25.9 2020.1 "Gastos", size(medium) color("219 112 41") place(e)) ///
		title("Ingreso y Gasto neto del Sector Público", margin(b+3) position(12)) ///
		subtitle("(Como porcentaje del PIB) 2000-2020", size(small) margin(b+3 t-3)) ///
		note("Fuente: Estadísticas Oportunas de Finanzas Públicas, SHCP / Elaborado por Azael Mateo (@xzxxlmxtxx)", size(small) margin(t+2) position(7)) ///
		xsize(9) ysize(5) ///
		name(graphs_balancepresup, replace)
		
graph export "$output\graphs_balancepres.png", width(1024) replace


*2.2. Ingresos

*2.2.1. Generamos variables de sumatorias para gráficar áreas.
generate isum1 = i_petroleros
generate isum2 = isum1+i_tribnopet
generate isum3 = isum2+i_notribnopet
generate isum4 =isum3+i_orgcontryempprodedo

*2.2.2. Graficamos
graph twoway ///
		area isum1 año if tin(2000,2020) || rarea isum1 isum2 año if tin(2000,2020) || ///
		rarea isum2 isum3 año if tin(2000,2020) || rarea isum3 isum4 año if tin(2000,2020), ///
		clwidth(thick thick) ///
		scheme(uncluttered) ///
		xtitle("") ///
		xscale(r(2000 2023)) ///
		xlabel(2000(1)2020, angle() labsize(*.8)) ///
		ytitle("Porcentaje del PIB", angle(v) size(*.8)) ///
		yscale(r(0 24)) ///
		ylabel(0(3)28, format(%5.0f)) ///
		text(1.5 2020.1 "Petroleros", size(small) color(black) place(e)) ///
		text(10 2020.1 "Tributarios", size(small) color(black) place(e)) ///
		text(18 2020.1 "No tributarios", size(small) color(black) place(e)) ///
		text(21 2020.1 "Issste/IMSS/CFE", size(small) color(black) place(e)) ///
		title("Ingresos Presupuestarios del Sector Público", margin(b+3) position(12)) ///
		subtitle("(Como porcentaje del PIB) 2000-2020", size(small) margin(b+3 t-3)) ///
		note("Fuente: Estadísticas Oportunas de Finanzas Públicas, SHCP / Elaborado por Azael Mateo (@xzxxlmxtxx)", size(small) margin(t+2) position(7)) ///
		legend(off) legend(order(1 "Petroleros" 2 "Tributarios" 3 "No tributarios" 4 "ISSSTE/IMSS/CFE") size(*.8) rows(1)) ///
		xsize(9) ysize(5) ///
		name(graphs_ingresos, replace)
		
graph export "$output\graphs_ingresos.png", width(1024) replace


*2.3. Gastos.

*2.3.2. Generamos variables de sumatorias para graficar áreas.
generate gsum1 = g_corrsinpens
generate gsum2 = gsum1+g_pensyjub
generate gsum3 = gsum2+g_capital
generate gsum4 =gsum3+g_costofin
generate gsum5 =gsum4+g_particip

*2.3.3. Graficamos.
graph twoway ///
		area gsum1 año if tin(2000,2020) || rarea gsum1 gsum2 año if tin(2000,2020) || ///
		rarea gsum2 gsum3 año if tin(2000,2020) || rarea gsum3 gsum4 año if tin(2000,2020) || ///
		rarea gsum4 gsum5 año if tin(2000,2020), ///
		clwidth(thick thick) ///
		scheme(uncluttered) ///
		xtitle("") ///
		xscale(r(2000 2023)) ///
		xlabel(2000(1)2020, angle() labsize(*.8)) ///
		ytitle("Porcentaje del PIB", angle(v) size(*.8)) ///
		yscale(r(0 24)) ///
		ylabel(0(3)28, format(%5.0f)) ///
		text(6 2020.1 "Corriente", size(small) color(black) place(e)) ///
				text(4.8 2020.1 "sin pensiones", size(small) color(black) place(e)) ///
		text(14.6 2020.1 "Pensiones y", size(small) color(black) place(e)) ///
				text(13.4 2020.1 "jubilaciones", size(small) color(black) place(e)) ///
		text(17.4 2020.1 "Capital", size(small) color(black) place(e)) ///
		text(20.7 2020.1 "Costo financiero", size(small) color(black) place(e)) ///
		text(24.5 2020.1 "Participaciones", size(small) color(black) place(e)) ///
		title("Gasto neto Presupuestario del Sector Público", margin(b+3) position(12)) ///
		subtitle("(Como porcentaje del PIB) 2000-2020", size(small) margin(b+3 t-3)) ///
		note("Fuente: Estadísticas Oportunas de Finanzas Públicas, SHCP / Elabrado por Azael Mateo (@xzxxlmxtxx)", size(small) margin(t+2) position(7)) ///
		legend(off) legend(order(1 "Corriente sin pensiones" 2 "Pensiones y jubilaciones" 3 "Capital" 4 "Costo financiero" 5 "Participaciones") ///
		size(*.8) rows(1)) ///
		xsize(9) ysize(5) ///
		name(graphs_gastos, replace)
		
graph export "$output\graphs_gastos.png", width(1024) replace
