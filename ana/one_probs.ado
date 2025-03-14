program define one_probs
	syntax, oname(string) dname(string)
	
	
	if strmatch("`dname'","D*") {
		local mat = "R"
	}
	else {
		local mat = "Q"
	}
	
	forvalues coh = 1/3 {
		forvalues puni = 0/1 {
			local Q `mat'_coh`coh'_puni`puni'
			matrix `Q'[rownumb(`Q',"`oname'"),colnumb(`Q',"`dname'")]= 1
		}
	}
	forvalues coh = 1/3 {
		forvalues fem = 0/1 {
			local Q `mat'_coh`coh'_fem`fem'
			matrix `Q'[rownumb(`Q',"`oname'"),colnumb(`Q',"`dname'")]= 1
		}
	}	
end

