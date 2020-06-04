* Encoding: UTF-8.

*Restructurin data into _R.sav.
VARSTOCASES
  /MAKE pain FROM pain1 pain2 pain3 pain4
  /INDEX=time(4) 
  /KEEP=ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness weight IQ 
    household_income 
  /NULL=KEEP.

*Data exploration.
DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness gender
  /STATISTICS=MEAN STDDEV MIN MAX.

EXAMINE VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness gender
  /PLOT BOXPLOT STEMLEAF HISTOGRAM
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Recode Sex into gender.
RECODE sex ('male'=0) ('female'=1) INTO gender.
EXECUTE.

*RANDOM INTERCEPT MODEL.
MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness time gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness time gender | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=FIXPRED PRED RESID.

*RANDOM SLOPE MODEL.
MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness time gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness time gender | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time | SUBJECT(ID) COVTYPE(UN)
  /SAVE=FIXPRED PRED RESID.

*Restructure data into _R_L1.sav.
VARSTOCASES
  /MAKE pain FROM pain pred_int pred_slope
  /INDEX=outcome(pain) 
  /KEEP=ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness weight IQ 
    household_income time gender fix_pred_int res_int fix_pred_slope res_slope 
  /NULL=KEEP.

*Split file on ID.
SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

*Pain and predicted values vs time by participant.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(pain)[name="MEAN_pain"] outcome 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: MEAN_pain=col(source(s), name("MEAN_pain"))
  DATA: outcome=col(source(s), name("outcome"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("Mean pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("outcome"))
  GUIDE: text.title(label("Multiple Line Mean of pain by time by outcome"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time*MEAN_pain), color.interior(outcome), missing.wings())
END GPL.

**Back to _R.sav**.

*Centering time.
COMPUTE time_centered=time-2.5.
EXECUTE.

*Centered time squared.
COMPUTE time_centered_sq=time_centered*time_centered.
EXECUTE.

*RANDOM SLOPE MODEL WITH TIME SQUARED (w/ SOLUTION).
MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness gender time_centered 
    time_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness gender time_centered time_centered_sq | 
    SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time_centered | SUBJECT(ID) COVTYPE(UN) solution
  /SAVE=FIXPRED PRED RESID.

*Restructure data into _R_L2.sav.
VARSTOCASES
  /MAKE pain FROM pain pred_time.sq
  /INDEX=outcome(pain) 
  /KEEP=ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness weight IQ 
    household_income time gender fix_pred_int pred_int res_int fix_pred_slope pred_slope res_slope 
    time_centered time_centered_sq fix_pred_time.sq res_time.sq 
  /NULL=KEEP.

*Split file on ID.
SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

*Pain and predicted values vs time by participant.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(pain)[name="MEAN_pain"] outcome 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: MEAN_pain=col(source(s), name("MEAN_pain"))
  DATA: outcome=col(source(s), name("outcome"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("Mean pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("outcome"))
  GUIDE: text.title(label("Multiple Line Mean of pain by time by outcome"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time*MEAN_pain), color.interior(outcome), missing.wings())
END GPL.

**Back to _R.sav**.

*MODEL DIAGNOSTICS.

*Influential observations.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time pain ID MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: pain=col(source(s), name("pain"), unit.category())
  DATA: ID=col(source(s), name("ID"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("ID"))
  GUIDE: text.title(label("Multiple Line of pain by time by ID"))
  ELEMENT: line(position(time*pain), color.interior(ID), missing.wings())
END GPL.

EXAMINE VARIABLES=pain BY ID
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS NONE
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Normality.
EXAMINE VARIABLES=res_time.sq
  /PLOT HISTOGRAM NPPLOT
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Linearity.
*vs predicted values.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pred_time.sq[name="pred_time_sq"] 
    res_time.sq[name="res_time_sq"] MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pred_time_sq=col(source(s), name("pred_time_sq"))
  DATA: res_time_sq=col(source(s), name("res_time_sq"))
  GUIDE: axis(dim(1), label("pred_time.sq"))
  GUIDE: axis(dim(2), label("res_time.sq"))
  GUIDE: text.title(label("Simple Scatter of res_time.sq by pred_time.sq"))
  ELEMENT: point(position(pred_time_sq*res_time_sq))
END GPL.

*vs age.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age res_time.sq[name="res_time_sq"] 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: res_time_sq=col(source(s), name("res_time_sq"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("res_time.sq"))
  GUIDE: text.title(label("Simple Scatter of res_time.sq by age"))
  ELEMENT: point(position(age*res_time_sq))
END GPL.

*vs time_centered.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_centered res_time.sq[name="res_time_sq"] 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_centered=col(source(s), name("time_centered"))
  DATA: res_time_sq=col(source(s), name("res_time_sq"))
  GUIDE: axis(dim(1), label("time_centered"))
  GUIDE: axis(dim(2), label("res_time.sq"))
  GUIDE: text.title(label("Simple Scatter of res_time.sq by time_centered"))
  ELEMENT: point(position(time_centered*res_time_sq))
END GPL.

*vs time_centered_sq.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_centered_sq 
    res_time.sq[name="res_time_sq"] MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_centered_sq=col(source(s), name("time_centered_sq"))
  DATA: res_time_sq=col(source(s), name("res_time_sq"))
  GUIDE: axis(dim(1), label("time_centered_sq"))
  GUIDE: axis(dim(2), label("res_time.sq"))
  GUIDE: text.title(label("Simple Scatter of res_time.sq by time_centered_sq"))
  ELEMENT: point(position(time_centered_sq*res_time_sq))
END GPL.

*Homoscedasticity.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pred_time.sq[name="pred_time_sq"] 
    res_time.sq[name="res_time_sq"] MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pred_time_sq=col(source(s), name("pred_time_sq"))
  DATA: res_time_sq=col(source(s), name("res_time_sq"))
  GUIDE: axis(dim(1), label("pred_time.sq"))
  GUIDE: axis(dim(2), label("res_time.sq"))
  GUIDE: text.title(label("Simple Scatter of res_time.sq by pred_time.sq"))
  ELEMENT: point(position(pred_time_sq*res_time_sq))
END GPL.

*Multicollinearity.
CORRELATIONS
  /VARIABLES=age STAI_trait pain_cat cortisol_serum mindfulness gender time_centered 
    time_centered_sq
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

*Constant variance of residuals acros clusters.
*Creating dummy variables for ID.
SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=ID_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.
*Creating res_sq.
COMPUTE res_time.sq_sq=res_time.sq*res_time.sq.
EXECUTE.
*Fitting a regression.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT res_time.sq_sq
  /METHOD=ENTER ID_dummy_2 ID_dummy_3 ID_dummy_4 ID_dummy_5 ID_dummy_6 ID_dummy_7 
    ID_dummy_8 ID_dummy_9 ID_dummy_10 ID_dummy_11 ID_dummy_12 ID_dummy_13 ID_dummy_14 ID_dummy_15 
    ID_dummy_16 ID_dummy_17 ID_dummy_18 ID_dummy_19 ID_dummy_20.

*Normal distribution of the random effects.
*Create random_effects.sav*
*Descriptives and normality plots.
EXAMINE VARIABLES=rnd_efcts
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.
*split the file between intercept and time.
SORT CASES  BY type.
SPLIT FILE SEPARATE BY type.
*Descriptives and normality plots.
EXAMINE VARIABLES=rnd_efcts
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Dependency structure of the random effects.
*Intepret the Correlation Matrix for Estimates of Covariance Parameters table.

*Discusion graphs.
*Figure 1 with daset _R_l3.sav containing the three models predictions.
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(pain)[name="MEAN_pain"] outcome 
    MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: time=col(source(s), name("time"), unit.category()) 
  DATA: MEAN_pain=col(source(s), name("MEAN_pain")) 
  DATA: outcome=col(source(s), name("outcome"), unit.category()) 
  GUIDE: axis(dim(1), label("time")) 
  GUIDE: axis(dim(2), label("Mean pain")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("outcome")) 
  GUIDE: text.title(label("Multiple Line Mean of pain by time by outcome")) 
  SCALE: linear(dim(2), include(0)) 
  ELEMENT: line(position(time*MEAN_pain), color.interior(outcome), missing.wings()) 
END GPL.

*Figure 2 with original long dataset _R.sav.
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(pain)[name="MEAN_pain"] sex 
    MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: time=col(source(s), name("time"), unit.category()) 
  DATA: MEAN_pain=col(source(s), name("MEAN_pain")) 
  DATA: sex=col(source(s), name("sex"), unit.category()) 
  GUIDE: axis(dim(1), label("time")) 
  GUIDE: axis(dim(2), label("Mean pain")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("sex")) 
  GUIDE: text.title(label("Multiple Line Mean of pain by time by sex")) 
  SCALE: linear(dim(2), include(0)) 
  ELEMENT: line(position(time*MEAN_pain), color.interior(sex), missing.wings()) 
END GPL.
