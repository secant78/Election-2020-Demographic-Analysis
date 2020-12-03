FILENAME REFFILE '/folders/myfolders/Election/president_county_candidate.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.election_results;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.election_results; RUN;

FILENAME REFFILE '/folders/myfolders/Election/racesex_data_edited_allvar.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.racesex;
	guessingrows=3000;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.racesex; RUN;

FILENAME REFFILE '/folders/myfolders/Election/edited_employment.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;



proc sql;
	create table employment_data as
	select SUBSTR(County_name_state_abbreviation, length(County_name_state_abbreviation)-1, 2) as state, 
	period,
	SUBSTR(County_name_state_abbreviation,1, length(County_name_state_abbreviation) - 4) as county, 
	labor_force, employed, 
	unemployed, unemployment_rate  from import
	where County_name_state_abbreviation IS NOT NULL AND County_name_state_abbreviation <> '' and period = 'Aug-20'
	group by state, county
	ORDER BY state, county;
quit;

data employment_data;
	set employment_data;
   labor_force = input(labor_force, 7.);
   employed = input(employed, 7.);
   unemployed = input(unemployed, 6.);
   unemployment_rate = input(unemployment_rate, 4.);
run;

proc sql; 
create table employment_data1 as
	select		
CASE
WHEN State = 'AK' THEN 'ALASKA'
WHEN State = 'AL' THEN 'ALABAMA'
WHEN State = 'AR' THEN 'ARKANSAS'
WHEN State= 'AS' THEN 'AMERICAN SAMOA'
WHEN State = 'AZ' THEN 'ARIZONA '
WHEN State = 'CA' THEN 'CALIFORNIA '
WHEN State = 'CO' THEN 'COLORADO '
WHEN State = 'CT' THEN 'CONNECTICUT'
WHEN State = 'DC' THEN 'DISTRICT OF COLUMBIA'
WHEN State = 'DE' THEN 'DELAWARE'
WHEN State = 'FL' THEN 'FLORIDA'
WHEN State = 'FM' THEN 'FEDERATED STATES OF MICRONESIA'
WHEN State = 'GA' THEN 'GEORGIA'
WHEN State = 'GU' THEN 'GUAM '
WHEN State = 'HI' THEN 'HAWAII'
WHEN State = 'IA' THEN 'IOWA'
WHEN State = 'ID' THEN 'IDAHO'
WHEN State = 'IL' THEN 'ILLINOIS'
WHEN State = 'IN' THEN 'INDIANA'
WHEN State = 'KS' THEN 'KANSAS'
WHEN State = 'KY' THEN 'KENTUCKY'
WHEN State = 'LA' THEN 'LOUISIANA'
WHEN State = 'MA' THEN 'MASSACHUSETTS'
WHEN State = 'MD' THEN 'MARYLAND'
WHEN State = 'ME' THEN 'MAINE'
WHEN State = 'MH' THEN 'MARSHALL ISLANDS'
WHEN State = 'MI' THEN 'MICHIGAN'
WHEN State = 'MN' THEN 'MINNESOTA'
WHEN State = 'MO' THEN 'MISSOURI'
WHEN State = 'MP' THEN 'NORTHERN MARIANA ISLANDS'
WHEN State = 'MS' THEN 'MISSISSIPPI'
WHEN State = 'MT' THEN 'MONTANA'
WHEN State = 'NC' THEN 'NORTH CAROLINA'
WHEN State = 'ND' THEN 'NORTH DAKOTA'
WHEN State = 'NE' THEN 'NEBRASKA'
WHEN State = 'NH' THEN 'NEW HAMPSHIRE'
WHEN State = 'NJ' THEN 'NEW JERSEY'
WHEN State = 'NM' THEN 'NEW MEXICO'
WHEN State = 'NV' THEN 'NEVADA'
WHEN State = 'NY' THEN 'NEW YORK'
WHEN State = 'OH' THEN 'OHIO'
WHEN State = 'OK' THEN 'OKLAHOMA'
WHEN State = 'OR' THEN 'OREGON'
WHEN State = 'PA' THEN 'PENNSYLVANIA'
WHEN State = 'PR' THEN 'PUERTO RICO'
WHEN State = 'RI' THEN 'RHODE ISLAND'
WHEN State = 'SC' THEN 'SOUTH CAROLINA'
WHEN State = 'SD' THEN 'SOUTH DAKOTA'
WHEN State = 'TN' THEN 'TENNESSEE'
WHEN State = 'TX' THEN 'TEXAS'
WHEN State = 'UT' THEN 'UTAH'
WHEN State = 'VA' THEN 'VIRGINIA '
WHEN State = 'VI' THEN 'VIRGIN ISLANDS'
WHEN State = 'VT' THEN 'VERMONT'
WHEN State = 'WA' THEN 'WASHINGTON'
WHEN State = 'WI' THEN 'WISCONSIN'
WHEN State = 'WV' THEN 'WEST VIRGINIA'
WHEN State = 'WY' THEN 'WYOMING'
ELSE '' END as state, period, county, labor_force, employed, 
	unemployed, unemployment_rate from employment_data
order by state, county;
quit;


	
proc sql;
	select distinct stname as counted_stname from import3;
quit;
proc sql;
	select distinct state as counted_stname from election_results;
quit;



data raceSex1;
	set racesex (drop = state county);
	rename CTYNAME = county;
	rename STNAME = state;
	black = BA_FEMALE + BA_MALE;
	white = WA_FEMALE + WA_MALE;
	asian = AA_FEMALE + AA_MALE;
	amerindian = IA_FEMALE + IA_MALE;
	pacific_islander = NA_FEMALE + NA_MALE;
	hispanic = H_FEMALE + H_MALE;
	
proc sql;
	create table raceSex1 as
	select upper(state) as state, raceSex1.*
	from raceSex1;
	quit;


proc sort data = election_results;
	by county;
	run;
	
data election_results1;
	set election_results;
	 where candidate = "Joe Biden" or candidate = "Donald Trump";
	run;
	
proc sql;
	create table election_results1 as
	select upper(state) as state, election_results1.*
	from election_results1;
	quit;
	
proc sort data = election_results1;
	by county;
	
proc print data = election_results1 (obs = 50);


PROC SQL;
CREATE TABLE won_counties AS
SELECT  *
FROM election_results1  a inner JOIN raceSex1 b
ON a.county = b.county and a.state = b.state
inner join employment_data1 c
on b.county = c.county and b.state = c.state
ORDER BY state, county;
QUIT;

proc sql;
create table won_counties1 as
select A.*, B.labor_force, B.employment, B.unemployment from won_counties A inner join employment_data1 B
on A.county = B.county and A.state = B.state
order by state, county;


PROC EXPORT DATA= won_counties
OUTFILE= "/folders/myfolders/Election/presidential_election_results_1.xlsx"
DBMS=XLSX REPLACE;
RUN;
