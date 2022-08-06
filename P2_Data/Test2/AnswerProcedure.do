*- usbirth
forvalues i = 2007/2020{
	insheet using usbirth`i'.txt, clear
	rename v1 region
	rename v2 county
	rename v3 year
	rename v4 nbirth
	rename v5 mage
	
	label var region "US census region"
	label var county "US countty"
	label var year   "data year"
	label var nbirth "number of births"
	label var mage   "average age of mother"
	save usbirth`i'.dta, replace
}

use usbirth2007.dta, clear
forvalues i = 2008/2020{
	append using usbirth`i'
}
sort county year
save usbirth.dta, replace

*- uscounty
foreach v in A B{
	insheet using uscounty`v'.txt, clear
	rename v1 county
	rename v2 year
	rename v3 tpop
	rename v4 fpop
	
	label var county "US countty"
	label var year   "data year"
	label var tpop "total population"
	label var fpop "famale population age 14-44"
	save uscounty`v'.dta, replace
}

use uscountyA.dta
append using uscountyB
sort county year
save uscounty.dta, replace

use usbirth.dta, clear
duplicates drop county year, force
merge 1:1 county year using uscounty.dta
drop _merge
save FinalData.dta, replace