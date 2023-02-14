
*****************************************************************************
version 15
clear all
set more off
gl output = "C:\Users\dell\Documents\Stata\Ejercicios\stata-graph-examples-master"
gl data = "C:\Users\dell\Documents\CEEY\Verano 2019\ENIGH\ENIGH 2018\ENIGH 2018 - MCS\enigh2018_ns_concentradohogar_dta"
gl shapes = "C:\Users\dell\Documents\Stata\Ejercicios\mapeodedatos"
cls
/*****************************************************************************************************************************************
 
Nombre archivo: 		AM_201907_ENIGH2016_Cálculos de ingreso pc mensual(v1)
Autor:          		Azael Mateo		
Máqina:        			Azael Mateo Personal                          				   				                         				   											
Fecha creación          11/Julio/2019                                         			   	   		   	                                         			  	
Modificaciones:		    19/Julio/2019
                        -Se replicaron los cálculos usando el Modelo Estadístico 2016 para la continuidad del 
						Modulo de Condiciones Socieonómicas de la ENIGH.
Archivos usados:     
	- Base ENIGH2016 (INEGI) "$data\AM_201907_ENIGH2016 (INEGI).dta"
	- STB-23, 
Archivos creados:  
	- Base con cálculos ENIGH2016 (INEGI) "$output\AM_201907_ENIGH2016 (INEGI)v1.dta"
Propósito:
	- Este archivo usa la base de datos ENIGH 2016 del INEGI (https://www.inegi.org.mx/programas/enigh/nc/2016/default.html#Datos_abiertos) 
	  y estima algunos calculos como el ingreso percapita mensual promedio de los hogares, el porcentaje de la población que tiene
	  ingresos mayores al ingreso percapita mensual promedio, etc. Con propositos comparativos también se una la base de datos ENIGH 2016
	  que usa CONEVAL (https://coneval.org.mx/Medicion/MP/Paginas/Programas_BD_10_12_14_16.aspx) y se realizan los mismos cálculos).

********************************************************************************************************************************************/



************************************
/**PRIMERA PARTE: PREPARAMOS BASE**/
************************************

*1.1. Cargamos la base que ocuparemos de la ENIGH2018.
cd "$output"
use "$data\concentradohogar.dta", clear
*1.2. Generamos una nueva variable para identificar a todos los municipios que integran a la Zona
*	  Metropolitana del Valle de la Ciudad de México (ZMVCM) y eliminamos el resto de las observaciones.
destring ubica_geo, generate(clave_mun)


****************************************
/**SEGUNDA PARTE: REALIZAMOS CÁLCULOS**/
****************************************

*2.1. Generamos scalar del número total de hogares.				 
summarize ing_cor [fw=factor] 
scalar TOThog = r(sum_w)
*2.2. Generamos scalar del número total de integrantes de los hogares (po. total).
summarize tot_integ [fw=factor] 
scalar TOTinteg = r(sum)
*2.3. Generamos scalar del promedio de integrantes por hogar.
scalar avg_integ = TOTinteg/TOThog
*2.4. Generamos scalar del ingreso trimestral total.
summarize ing_cor [fw=factor]
scalar TOTing_cor = r(sum)
*2.5. Generamos variable del ingreso mensual.
generate ing_cormens = ing_cor/3
label variable ing_cormens "Ingreso mensual del Hogar"
*2.6. Generamos variable del ingreso mensual pc.
generate ing_cormens_pc = ing_cormens/tot_integ
label variable ing_cormens_pc "Ingreso mensual pc en el Hogar"
*2.7. Generamos scalar de la línea de pobreza y pobreza extrema (3/2018).
scalar lpe_urb = 1516.62
scalar lpne_urb = 3001.17
*2.8. Generamos scalar del ingreso promedio mensual de los hogares en México.
summ ing_cormens [fw=factor]
scalar zmvcm_avgingmens = r(mean)
*2.9. Generamos variable del ingreso promedio mensual de los hogares en México por entidad.
generate clave_ent = substr(ubica_geo,1,2), after(ubica_geo)
destring clave_ent, replace
generate ing_cormens_ent = .
label variable ing_cormens_ent "Ingreso promedio mensual de los hogares en la entidad"
levelsof clave_ent, local(estados)
foreach v of local estados {
cap summarize ing_cormens [fw=factor] if clave_ent == `v'
scalar entidad`v' = r(mean)
replace ing_cormens_ent = r(mean) if clave_ent == `v'
}
*2.10. Generamos variable del ingreso promedio mensual de los hogares de México por municipio.
generate ing_cormens_mun = .
label variable ing_cormens_mun "Ingreso promedio mensual de los hogares en el municipio"
levelsof clave_mun, local(municipios)
foreach v of local municipios {
cap summarize ing_cormens [fw=factor] if clave_mun == `v'
scalar municipio`v' = r(mean)
replace ing_cormens_mun = r(mean) if clave_mun == `v'
}
format %9.0fc ing_cormens_mun
format %9.0fc ing_cormens_ent
*2.11. Generamos scalar del ingreso promedio de los hogares por entidad y por municipio.
summarize ing_cormens_ent
scalar avgingent = r(m)
summarize ing_cormens_mun
scalar avgingmun = r(m)


*************************************
/**TERCERA PARTE: REALIZAMOS MAPAS**/
*************************************

*3.1. Nacional. Entidades Federativas.
preserve
*3.1.1. Preparamos base.
keep clave_ent ing_cormens_ent 
duplicates drop 
*3.1.2. Hacemos merge con el shape de estados.
tempfile temp
save `temp', replace
cd "$shapes\mge2005v_1_0"
shp2dta using Entidades_2005.shp, database("ent-d.dta") coordinates("ent-c.dta") genid(id) replace 
use ent-d, clear
gen clave_ent=CVE_EDO
sort clave_ent
destring clave_ent, replace
save base, replace
use `temp', clear
merge m:m clave_ent using "base.dta", force
*3.1.3. Creamos mapa.
spmap ing_cormens_ent using ent-c, ///
id(id) clnumber(10) clmethod() fcolor(RdBu) ///
ndlab("Sin datos") ndfcolor(gs13) ndocolor(none ..) ///
ocolor(white ..) osize(vvthin ..) ///
legend(title("Decil de Ingresos", size(vsmall) margin(small)) position(7) size(*.8)) ///
legstyle(2) legorder(hilo) legcount ///
title("Ingreso promedio mensual en los Hogares", size(*.8)) ///
subtitle("Entidades Federativas", size(*.8)) ///
scalebar(units(1000) scale(1/1000) xpos(100) label(Kilometros)) ///
note("Fuente: ENIGH 2018, INEGI. @xzxxlmxtxx", size(vsmall) position(7)) 
graph export "$output\AM201911_IngresoPromMen(Nacional-AGEM).png", width(1024) replace
restore

*3.2. Nacional. Municipios.
preserve
*3.2.1. Preparamos base.
keep clave_mun ing_cormens_mun 
duplicates drop 
*3.2.2. Hacemos merge con el shape de municipios.
tempfile temp
save `temp', replace
cd "$shapes\mgm2005v_1_0"
shp2dta using Municipios_2005.shp, database("mun-d.dta") coordinates("mun-c.dta") genid(id) replace 
use mun-d, clear
gen clave_mun=CVE_CONCA
sort clave_mun
destring clave_mun, replace
save base, replace
use `temp', clear
merge m:m clave_mun using "base.dta", force
*3.1.3. Creamos mapa.
spmap ing_cormens_mun using mun-c, ///
id(id) clnumber(9) clmethod() fcolor(BuPu) ///
ndlab("Sin datos") ndfcolor(gs13) ndocolor(none ..) ///
ocolor(black ..) osize(vvthin ..) ///
polygon(data("ent-c.dta") osize(vvthin ..) ocolor(white ..))  ///
legend(title("Intervalos de Ingreso", size(vsmall) margin(small)) position(7) size(*.8)) ///
legstyle(2) legorder(hilo) legcount ///
title("Ingreso promedio mensual en los Hogares", size(*.8)) ///
subtitle("Zona Metropolitana del Valle de México", size(*.8)) ///
scalebar(units(1000) scale(1/1000) xpos(100) label(Kilometros)) ///
note("Fuente: INEGI. @xzxxlmxtxx", size(vsmall) position(7)) 
graph export "$output\IngresoPromMen(Nacional-AGEMM).png", width(1024) replace
restore

*3.3. ZMVCM. Municipios.
preserve
*3.3.1. Preparamos base.
	*3.2.1. Preparamos base.
	keep clave_mun ing_cormens_mun 
	duplicates drop 
	*3.2.2. Hacemos merge con el shape de municipios.
	tempfile temp
	save `temp', replace
	cd "$shapes\mgm2005v_1_0"
	shp2dta using Municipios_2005.shp, database("mun-d.dta") coordinates("mun-c.dta") genid(id) replace 
	use mun-d, clear
	gen clave_mun=CVE_CONCA
	sort clave_mun
	destring clave_mun, replace
	save base, replace
	use `temp', clear
	merge m:m clave_mun using "base.dta", force
*3.3.2. Eliminamos todos los municipios que no son parte de la ZMVCD.
keep if clave_mun ==09002 | clave_mun ==09003 | clave_mun ==09004 | clave_mun ==09005 | clave_mun ==09006 | clave_mun ==09007 | clave_mun ==09008 | ///
		clave_mun ==09009 | clave_mun ==09010 | clave_mun ==09011 | clave_mun ==09012 | clave_mun ==09013 | clave_mun ==09014 | clave_mun ==09015 | ///
		clave_mun ==09016 | clave_mun ==09017 | clave_mun ==13069 | clave_mun ==15002 | clave_mun ==15009 | clave_mun ==15010 | clave_mun ==15011 | ///
		clave_mun ==15013 | clave_mun ==15015 | clave_mun ==15016 | clave_mun ==15017 | clave_mun ==15020 | clave_mun ==15022 | clave_mun ==15023 | ///
		clave_mun ==15024 | clave_mun ==15025 | clave_mun ==15028 | clave_mun ==15029 | clave_mun ==15030 | clave_mun ==15031 | clave_mun ==15033 | ///
		clave_mun ==15034 | clave_mun ==15035 | clave_mun ==15036 | clave_mun ==15037 | clave_mun ==15038 | clave_mun ==15039 | clave_mun ==15044 | ///
		clave_mun ==15046 | clave_mun ==15050 | clave_mun ==15053 | clave_mun ==15057 | clave_mun ==15058 | clave_mun ==15059 | clave_mun ==15060 | ///
		clave_mun ==15061 | clave_mun ==15065 | clave_mun ==15068 | clave_mun ==15069 | clave_mun ==15070 | clave_mun ==15075 | clave_mun ==15081 | ///
		clave_mun ==15083 | clave_mun ==15084 | clave_mun ==15089 | clave_mun ==15091 | clave_mun ==15092 | clave_mun ==15093 | clave_mun ==15094 | ///
		clave_mun ==15095 | clave_mun ==15096 | clave_mun ==15099 | clave_mun ==15100 | clave_mun ==15103 | clave_mun ==15104 | clave_mun ==15108 | ///
		clave_mun ==15109 | clave_mun ==15112 | clave_mun ==15120 | clave_mun ==15121 | clave_mun ==15122 | clave_mun ==15125
*3.1. Creamos el mapa.
spmap ing_cormens_mun using mun-c, ///
id(id) clnumber(9) clmethod() fcolor(BuPu) ///
ndlab("Sin datos") ndfcolor(gs13) ndocolor(none ..) ///
ocolor(black ..) osize(vvthin ..) ///
polygon(data("ent-c.dta") select(keep if _ID == 13 | _ID == 14 | _ID == 17) osize(vthin ..))  ///
legend(title("Intervalos de Ingreso", size(vsmall) margin(small)) position(7) size(*.8)) ///
legstyle(2) legorder(hilo) legcount ///
title("Ingreso promedio mensual en los Hogares", size(*.8)) ///
subtitle("Zona Metropolitana del Valle de México", size(*.8)) ///
scalebar(units(50) scale(1/1000) xpos(100) label(Kilometros)) ///
note("Fuente: INEGI. @xzxxlmxtxx", size(vsmall) position(7)) 
graph export "$output\AM201911_IngresoProm(ZMVM-AGEMM).png", width(1024) replace
restore


*******************************************
/**CUARTA PARTE: CÁLCULOS DE DESIGUALDAD**/
*******************************************

*4.1. Instalamos la paqueteria necesaria.
net install sg30.pkg, replace
net install st0457.pkg, replace
*4.2. Calculamos coeficiente de desigualdad.
inequal ing_cormens_ent
*4.3. Calculamos la Curva de Lorenz.
lorenz ing_cormens_ent, grap

************************************************************************************************************************************************	
	
*legend(label(1 "1") label(2 "2") label(3 "3") label(4 "4")) ///


