program define est_probs
	syntax varlist , orig(string) dest(string)  at(name)
	
	Parse `orig'
	local onum  = r(num1)
	local oname = r(name1)
	Parse `dest'
	local k = r(k)
	forvalues i = 1/`k' {
		local dnum`i'  = r(num`i')
		local dname`i' = r(name`i') 
	}
	
	version 5: mlogit dest `varlist'  if orig == `onum'
	local eqnames  : coleq e(b), quoted
	local eqnames  : list uniq eqnames
	mata: predict_pr()
	matlist(pr)
	
	/*
	forvalues i = 1/`k' {
		Fill_table, destnum(`dnum`i'') destname("`dname`i''") ///
		            orignum(`onum') origname("`oname'") 
	}
	*/
	
end

program define Parse, rclass
	syntax anything(name=string)
	tokenize `string', parse(;)
	local i = 1
	local j = 1
	while `"``i''"' != "" {
		if `"``i''"' != ";" {
			gettoken num name : `i'
			return scalar num`j'    = `num'
			return local  name`j++'   `name'
		}
		local i = `i' + 1
	}
	return scalar k = `j'-1
end

program define Fill_table
	syntax, destnum(integer) destname(string) origname(string) orignum(integer)
	if `destnum' == 0 {
		local mat = "R"
	}
	else {
		local mat = "Q"
	}
	
	mlogit dest i.co##(i.puni i.mig)  if orig == `orignum'
	qui margins, over(coh puni) at(mig=0) nose predict(pr outcome(`destnum'))
	forvalues coh = 1/3 {
		forvalues puni = 0/1 {
			local Q `mat'_coh`coh'_puni`puni' 
			matrix `Q'[rownumb(`Q',"`origname'"),colnumb(`Q',"`destname'")]= ///
			el(r(table),1,colnumb(r(table),"`coh'.coh#`puni'.puni"))
		}
	}
	mlogit dest i.co##(i.female i.mig)  if orig == `orignum'
	qui margins, over(coh female) at(mig=0) nose predict(pr outcome(`destnum'))
	forvalues coh = 1/3 {
		forvalues fem = 0/1 {
			local Q `mat'_coh`coh'_fem`fem' 
			matrix `Q'[rownumb(`Q',"`origname'"),colnumb(`Q',"`destname'")]= ///
			el(r(table),1,colnumb(r(table),"`coh'.coh#`fem'.female"))
		}
	}
end
	
mata :
void predict_pr()
{
	real   vector b, x, who, expxb, p
	real   matrix bsplit
	real   scalar i, denom
	string matrix stripe
	string vector var, eq
	
	// collect info from Stata
	var    = tokens(st_local("varlist")), "_cons"
	eq     = tokens(st_local("eqnames"))
	b      = st_matrix("e(b)")
	stripe = st_matrixcolstripe("e(b)")
	x      = st_matrix(st_local("at"))
	
	// split b by equation
	bsplit = J(0,cols(var),.)
	for(i=1; i<=cols(eq); i++) {
		who = selectindex(stripe[.,1]:==eq[i])
		bsplit = bsplit \ b[who']
	}

	// compute probablities
	expxb = J(1, cols(x),1)\exp(bsplit*x)
	denom = colsum(expxb) 
	p = expxb:/denom
	st_matrix("pr", p)
}
end
