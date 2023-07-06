
library(tidyverse)
#---------
# C&I Scorecard Redevelopment
#---------

con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "AMBBOSPSSQL1\\MSSQLSERVER2016",
                 Database = "RH_BXS_2022",
                 trusted_connection = TRUE)

{
  BXS_cni_all <- dbGetQuery(con, "
select 
*
from
(select 
	  a.processing_date
	, a.customer_num
	, a.acct_num
	, a.Pers_Comm_Indicator
	, a.Call_Code
	, a.average_balance
	, a.current_book_principal
	, a.cmt_available
	, a.PAST_DUE_IN_DAYS
	, a.NON_ACCRUAL
	, a.COLLATERAL_CODE
	, a.PURPOSE_CODE
	, a.collateral_value
	, a.original_trans_purch_date
	, a.renewal_date
	, a.current_maturity_date
	, a.NEXT_MONTH_RISK_RATING
	, a.NEXT_MONTH_PD
	, a.NEXT_MONTH_LGD
	, a.NEXT_MONTH_EAD
	, a.RISK_RATING
	, a.CREDIT_SCORE
	, a.LOAN_TYPE
	, a.OCCUPATION
	, a.ON_US_DEPOSIT
	, a.TOTAL_DEPOSIT
	, a.INDIRECT_LOAN
	, a.CREDIT_LIMIT
	, a.INDUSTRY_STANDING
	, a.PROF_MRGN_TREND
	, a.GUAR_CREDIT_SCORE
	, a.TENANT_BASE
	, a.OCCUPANCY_PCT
	, a.DEBT_SVC_CVRG
	, a.YEARS_OF_EXPERIENCE
	, a.COMPANY_AGE
	, a.INTEREST_CVG
	, a.EBI_TDA
	, a.CURRENT_RATIO
	, a.RETAINED_EARNINGS
	, a.CURRENT_LIABILITIES
	, a.SIC_CODE
	, a.TOTAL_ASSETS
	, a.GROSS_SALES
	, a.TOTAL_LIABILITIES
	, a.CREDIT_RISK_RATING_CODE
	, a.ORIGINAL_BOOK_VALUE
	, a.LOAN_PROCESSING_TYPE
	, a.INCOME
	, a.PROJECT_STATE
	, a.PROJECT_COUNTY
	, a.PROJECT_LOCATION_MSA
	, a.CURRENT_LTV
	, a.LOAN_NUM_TIMES_GT_30_PD
	, a.LOAN_NUM_TIMES_GT_60_PD
	, a.LOAN_NUM_TIMES_GT_90_PD
	, a.LOAN_NUM_TIMES_GT_120_PD
	, a.PROJECT_LOAN_COST_RATIO
	, a.DCR
	, a.COMBINED_LTV
	, a.PROJECT_PRE_SOLD_LEASED_PCT
	, a.STATUS
	, a.STAND_LTV
	, a.SUBSYSID
	, a.TRANSFERRED_ACCOUNT
	, a.NEXT_MONTH_TOTAL_POINTS
	, default_date
	, default_year
	, (year(A.processing_date)+1) as portfolio_year
	, b.Portfolio
	, Dflt.Portfolio as default_portfolio
	, (case when Dflt.portfolio =  'Impaired' then b.portfolio else Dflt.portfolio end) as true_portfolio
	, Dflt.year_scorecard as defaulted_scorecard
	, e.year_scorecard as prior_scorecard
	, (case when Dflt.acct_num is NULL then 0 else 1 end) as Default_Flag
	, default_90dpd
	, default_nac1
	, default_chargeoff

from EriskData_2008to2022 A
left join a_BXS_Scorecard_Map B	
on A.score_card = B.score_card	
--identifies to which scorecard each loan in 'A' belongs

left join zz_exclude_list c
on c.acct_num = a.acct_num and a.processing_date = c.processing_date

left join b_Year_ScoreCard_Map2022 e  
on year(A.processing_date) = e.[year] and B.portfolio = e.[scorecard]	
-- maps loans to scorecard-year	

left join  zz_default_list Dflt
on Dflt.acct_num = a.acct_num and Dflt.default_year = (year(A.processing_date)+1)


where A.processing_date in ('11/30/2008','6/30/2008','6/30/2009','6/30/2010',
'6/30/2011','6/30/2012','6/30/2013','6/30/2014','6/30/2015','6/30/2016',
'6/30/2017','6/30/2018','6/30/2019', '6/30/2020', '6/30/2021')
and (A.current_book_principal+A.cmt_available) >'0'
and c.acct_num is null
--and Dflt.acct_num is not null
) a

left join b_Year_ScoreCard_Map2022 b  
on a.default_year = b.[year] and b.scorecard = a.true_portfolio	
 
where portfolio = 'Commercial & Industrial'

order by processing_date
")
}
# 
# Rows: 21,098
# Columns: 81
# $ processing_date             <dttm> 2008-11-30, 2008-11-30, 2008-11-30, 2008-11-30, 2~
# $ acct_num                    <chr> "ALS_00010200014203", "ALS_00057000209332", "ALS_0~
# $ Call_Code                   <chr> "04A0", "04A0", "04A0", "04A0", "04A0", "04A0", "0~
# $ current_book_principal      <dbl> 0.00, 0.00, 1200000.00, 0.00, 755478.58, 435000.00~
# $ cmt_available               <dbl> 2875000.0, 1000000.0, 1300000.0, 5000000.0, 123452~
# $ PAST_DUE_IN_DAYS            <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,~
# $ NON_ACCRUAL                 <chr> "NAC_2", "NAC_2", "NAC_2", "NAC_2", "NAC_2", "NAC_~
# $ COLLATERAL_CODE             <chr> "33", "33", "1", "1", "1", "15", "1", "1", "R2", "~
# $ PURPOSE_CODE                <chr> "310", "310", "310", "310", "310", "310", "310", "~
# $ collateral_value            <dbl> 3132724, 1250000, 8819435, 6250000, 1875748, 28796~
# $ original_trans_purch_date   <dttm> 1996-05-08, 2008-04-01, 2005-04-01, 2008-06-02, 2~
# $ renewal_date                <dttm> 1996-05-08, 2008-04-01, 2005-04-01, 2008-06-02, 2~
# $ current_maturity_date       <dttm> 2009-08-01, 2009-04-01, 2009-04-01, 2009-04-01, 2~
# $ NEXT_MONTH_RISK_RATING      <int> 4, 12, 5, 6, 3, 13, 9, 6, 11, 10, 9, 10, 8, 9, 4, ~
# $ NEXT_MONTH_PD               <dbl> 0.0047, 0.0268, 0.0066, 0.0070, 0.0028, 0.0502, 0.~
# $ NEXT_MONTH_LGD              <dbl> 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 10, 20~
# $ NEXT_MONTH_EAD              <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ RISK_RATING                 <chr> "", "", "", "", "", "", "", "", "", "", "", "", ""~
# $ CREDIT_SCORE                <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ LOAN_TYPE                   <int> 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,~
# $ OCCUPATION                  <int> 54, 17, 61, 17, 66, 17, 61, 54, 17, 61, 72, 68, 17~
# $ ON_US_DEPOSIT               <chr> "Y", "Y", "Y", "Y", "Y", "Y", "N", "N", "Y", "Y", ~
# $ TOTAL_DEPOSIT               <dbl> 7572866, 1307504, 12075, 6670698, 958, 193301, 0, ~
# $ INDIRECT_LOAN               <int> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,~
# $ CREDIT_LIMIT                <dbl> 3000000, 1000000, 2000000, 5000000, 1300000, 50000~
# $ INDUSTRY_STANDING           <int> 3, 1, 3, 1, 3, 1, 3, 2, 3, 5, 3, 5, 1, 3, 3, 1, 1,~
# $ PROF_MRGN_TREND             <int> 2, 3, 2, 1, 1, 3, 1, 1, 3, 2, 3, 2, 2, 3, 2, 3, 1,~
# $ GUAR_CREDIT_SCORE           <int> 775, 0, 700, 0, 773, 0, 571, 700, 717, 797, 700, 7~
# $ TENANT_BASE                 <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ DEBT_SVC_CVRG               <dbl> 202.00, 0.00, 162.00, 315.00, 248.00, 0.00, 0.00, ~
# $ YEARS_OF_EXPERIENCE         <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ COMPANY_AGE                 <dbl> 50, 0, 35, 0, 6, 0, 9, 10, 0, 19, 7, 51, 0, 7, 40,~
# $ INTEREST_CVG                <dbl> 111.00, 0.00, 320.00, 999.00, 248.00, 0.00, 12.39,~
# $ EBI_TDA                     <dbl> 1196000, 0, 1241000, 3548000, 1750000, 0, 948010, ~
# $ CURRENT_RATIO               <dbl> 181.00, 0.00, 166.00, 234.00, 135.00, 0.00, 1.21, ~
# $ RETAINED_EARNINGS           <dbl> 2212000, 0, 9204000, 2539000, 2710000, 0, 31, 1346~
# $ CURRENT_LIABILITIES         <dbl> 12126000, 0, 8641000, 5132000, 3037000, 0, 2003000~
# $ SIC_CODE                    <chr> "INVALID", "2086", "3593", "1611", "INVALID", "INV~
# $ TOTAL_ASSETS                <dbl> 25697000, 0, 22849000, 18064000, 7601000, 0, 30570~
# $ GROSS_SALES                 <dbl> 69248000, 0, 56009000, 35150000, 13637000, 0, 1959~
# $ TOTAL_LIABILITIES           <dbl> 22771000, 0, 13508000, 15425000, 3037000, 0, 23060~
# $ ORIGINAL_BOOK_VALUE         <dbl> 250000.0, 0.0, 0.0, 7560.0, 0.0, 76599.9, 215592.7~
# $ LOAN_PROCESSING_TYPE        <chr> "01", "01", "01", "01", "01", "01", "01", "01", "0~
# $ CURRENT_LTV                 <dbl> 0.000000e+00, 0.000000e+00, 1.360631e+01, 0.000000~
# $ LOAN_NUM_TIMES_GT_30_PD     <int> 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ LOAN_NUM_TIMES_GT_60_PD     <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ LOAN_NUM_TIMES_GT_90_PD     <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ LOAN_NUM_TIMES_GT_120_PD    <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ DCR                         <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ COMBINED_LTV                <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ NEXT_MONTH_TOTAL_POINTS     <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ default_date                <dttm> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N~
# $ default_year                <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ portfolio_year              <int> 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 20~
# $ Portfolio                   <chr> "Commercial & Industrial", "Commercial & Industria~
# $ default_portfolio           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ true_portfolio              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ defaulted_scorecard         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ prior_scorecard             <chr> "C&I 2008", "C&I 2008", "C&I 2008", "C&I 2008", "C~
# $ Default_Flag                <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,~
# $ default_90dpd               <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ default_nac1                <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ default_chargeoff           <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ ScoreCard                   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
# $ Year                        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~

#----------------------------
# BXS C&I Data Summary
BXS_cni_summary <- 
  BXS_cni_all %>% 
  summarize(count = n(),
            default = hablar::sum_(Default_Flag),
            def_rate = default / count,
            rating = hablar::mean_(NEXT_MONTH_RISK_RATING))
#--------------------------

# Default Rate by Discrete Risk Factor Function
PlotDiscrete <- function(i_variable) {  
  
  # First we look at the distribution by code
  var_name = tools::toTitleCase(gsub("_", " ", i_variable))
   
  p1 <-
    BXS_cni_all %>% 
    ggplot(aes(x = get(i_variable))) + geom_bar(stat = "count") + theme_bw() +
    xlab(var_name) +
    ylab("Count") +
    ggtitle("LBXS C&I Scorecard Accounts", 
            paste(var_name, "Distribution")) +
    theme(axis.text.x = element_text(angle = 90))
  
  
  # 2. Next we look at default rate by call code
  p2 <-   
      BXS_cni_all %>%
      group_by(!!i_variable := get(i_variable)) %>% 
      summarize(count = n(),
                default = hablar::sum_(Default_Flag),
                def_rate = default / count,
                rating = hablar::mean_(NEXT_MONTH_RISK_RATING)) %>% 
      mutate(across(count:rating, ~ifelse(count < 100, NA, .))) %>% # Hide the rows with low counts
      ggplot(aes(x = get(i_variable), y = def_rate)) +
      geom_point(aes(size = count), color = "grey40")+
      geom_abline(intercept = BXS_cni_summary$def_rate, slope = 0, color = "grey40", lty = "dashed")+
      theme_bw() +
      xlab(var_name) +
      scale_y_continuous(name = "Observed Default Rate",
                         labels = scales::percent) +
      ggtitle("LBXS C&I Scorecard Accounts", 
              paste("Default Rate by", var_name)) +
      theme(axis.text.x = element_text(angle = 90)) 
  
  print(p1)
  print(p2)
}

# Discrete Variables List
#------------------------
# $ Call_Code                   <chr> "04A0", "04A0", "04A0", "04A0", "04A0", "04A0", "0~
# $ COLLATERAL_CODE             <chr> "33", "33", "1", "1", "1", "15", "1", "1", "R2", "~
# $ PURPOSE_CODE                <chr> "310", "310", "310", "310", "310", "310", "310", "~
# $ OCCUPATION                  <int> 54, 17, 61, 17, 66, 17, 61, 54, 17, 61, 72, 68, 17~
# $ ON_US_DEPOSIT               <chr> "Y", "Y", "Y", "Y", "Y", "Y", "N", "N", "Y", "Y", ~
# $ INDUSTRY_STANDING           <int> 3, 1, 3, 1, 3, 1, 3, 2, 3, 5, 3, 5, 1, 3, 3, 1, 1,~
# $ PROF_MRGN_TREND             <int> 2, 3, 2, 1, 1, 3, 1, 1, 3, 2, 3, 2, 2, 3, 2, 3, 1,~
# $ SIC_CODE                    <chr> "INVALID", "2086", "3593", "1611", "INVALID", "INV~
# $ LOAN_PROCESSING_TYPE        <chr> "01", "01", "01", "01", "01", "01", "01", "01", "0~

PlotDiscrete("Call_Code")
PlotDiscrete("COLLATERAL_CODE")
PlotDiscrete("PURPOSE_CODE")
PlotDiscrete("OCCUPATION")
PlotDiscrete("ON_US_DEPOSIT")
PlotDiscrete("INDUSTRY_STANDING")
PlotDiscrete("PROF_MRGN_TREND")
PlotDiscrete("SIC_CODE")
PlotDiscrete("LOAN_PROCESSING_TYPE")


