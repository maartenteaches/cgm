program define fastmlogit, rclass 
	syntax varlist, at(passthru)
	
	gettoken y x : varlist
	
	version 5: mlogit `y' `x'
	
	local varnames : colnames e(b)
	local varnames : list uniq varnames
	local eqnames  : coleq e(b), quoted
	local eqnames  : list uniq eqnames

	Parse_at, `at' varnames(`varnames')
	
	tempname pr
	
	mata:predict_pr()
	
	local rnames = strtoname(e(baselab))
	foreach lab of local eqnames {
		local rnames = "`rnames' " + strtoname("`lab'")
	}
	matrix rownames `pr' = `rnames'
	matrix colnames `pr' = "pr"
	
	return matrix pr = `pr'
end					

program define Parse_at, rclass
	syntax, at(string) varnames(string)
	
	local k : word count `varnames'
	tempname atx
	matrix `atx' = J(`k',1,0)
	matrix rownames `atx' = `varnames'
	matrix `atx'[`k',1] = 1
	
	local atk : word count `at'
	if mod(`atk',2) == 1 {
		di as err "{p}The at() option should contain an even number of arguments{p_end}"
		exit 198
	}
	numlist "1(2)`atk'"
	local nums = r(numlist)
	foreach i of local nums {
		local what : word `i' of `at'
		local val : word `=`i' + 1' of `at'
		
		Chk_whatval, what("`what'") val("`val'") varnames("`varnames'")
		where_in_varname, varnames("`varnames'") what("`what'")
		matrix `atx'[`r(where)',1] = `val'
	}
	return matrix atx = `atx'
end

program define Chk_whatval
	syntax , what(string) val(string) varnames(string)
	
	if !`:list what in varnames' {
		di as err "{p}The uneven lements in at() should be a variable name of a variable in the mlogit model{p_end}"
		exit 198
	}
	capture confirm number `val'
	if _rc {
		di as err "{p}The even elements in at() should be a number{p_end}"
		exit 198
	}
end

program define where_in_varname, rclass
	syntax, varnames(string) what(string)
	
	local where = ustrpos("`varnames'", "`what'")-1
	if `where' == 0 {
		local ret = 0
	}
	else {
		local varnames = usubstr("`varnames'",1,`where')
		local ret : word count `varnames'
	}
	return scalar where = `ret' + 1
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
	var    = tokens(st_local("varnames"))
	eq     = tokens(st_local("eqnames"))
	b      = st_matrix("e(b)")
	stripe = st_matrixcolstripe("e(b)")
	x      = st_matrix("r(atx)")
	
	// split b by equation
	bsplit = J(0,cols(var),.)
	for(i=1; i<=cols(eq); i++) {
		who = selectindex(stripe[.,1]:==eq[i])
		bsplit = bsplit \ b[who']
	}

	// compute probablities
	expxb = 1\exp(bsplit*x)
	denom = sum(expxb) 
	p = expxb/denom
	st_matrix(st_local("pr"), p)
}
end