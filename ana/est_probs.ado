program define est_probs
	syntax, orig(passthru) dest(passthru)
	
	local xpuni = "         coh2        coh3        coh4" 
	local xpuni = "`xpuni'  puni        mig"
	local xpuni = "`xpuni'  coh2Xpuni   coh3Xpuni   coh4Xpuni"
	local xpuni = "`xpuni'  coh2Xmig    coh3Xmig    coh4Xmig"

	local xfem = "        coh2        coh3        coh4" 
	local xfem = "`xfem'  female      mig"
	local xfem = "`xfem'  coh2Xfemale coh3Xfemale coh4Xfemale"
	local xfem = "`xfem'  coh2Xmig    coh3Xmig    coh4Xmig"
	
	Main `xpuni', `orig' `dest' what("puni")
	Main `xfem', `orig' `dest' what("fem")
end

program define Main
	syntax varlist , orig(string) dest(string)  what(string)
	
	Parse `orig'
	local onum  = r(num1)
	local oname = r(name1)
	Parse `dest'
	local k = r(k)
	local rownames = ""
	forvalues i = 1/`k' {
		local dnum`i'  = r(num`i')
		local dname`i' = r(name`i') 
		local rownames = "`rownames' `dname`i''"
	}
	
	version 5: mlogit dest `varlist'  if orig == `onum', baseoutcome(`dnum1')
	local eqnames  : coleq e(b), quoted
	local eqnames  : list uniq eqnames
	mata: predict_pr()
	matrix rownames pr = `rownames'

	forvalues i = 1/`k' {
		Fill_table, destnum(`dnum`i'') destname("`dname`i''") ///
		            orignum(`onum') origname("`oname'")  row(`i') what(`what')
	}
	
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
	syntax, destnum(integer) destname(string) origname(string) orignum(integer) row(integer) what(string)
	if `destnum' == 0 {
		local mat = "R"
	}
	else {
		local mat = "Q"
	}

	local col = 1
	forvalues coh = 1/4 {
		forvalues val = 0/1 {
			local Q `mat'_coh`coh'_`what'`val' 
			matrix `Q'[rownumb(`Q',"`origname'"),colnumb(`Q',"`destname'")]= ///
			el(pr,`row',`col++')
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
	x      = st_matrix("at" + st_local("what"))
	
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
