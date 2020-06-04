* Encoding: UTF-8.

*Exploring the dataset.
DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.

*Recode pain excluding coding errors.
RECODE pain (11 thru Highest=SYSMIS) (ELSE=Copy) INTO pain_2.
EXECUTE.

*Recode mindfulness excluding coding errors.
RECODE mindfulness (6.0001 thru Highest=SYSMIS) (ELSE=Copy) INTO mindfulness_2.
EXECUTE.

*Recode sex into gender. 
RECODE sex ('female'=1) ('woman'=1) ('male'=0) INTO gender.
EXECUTE.

*Further exploring the dataset.
FREQUENCIES VARIABLES=pain_2 age STAI_trait pain_cat cortisol_serum mindfulness_2 gender
  /STATISTICS=STDDEV MEAN MEDIAN SKEWNESS SESKEW KURTOSIS SEKURT
  /HISTOGRAM
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=pain_2 gender age STAI_trait pain_cat cortisol_serum cortisol_saliva 
    mindfulness_2
  /STATISTICS=MEAN STDDEV MIN MAX.

CORRELATIONS
  /VARIABLES=pain_2 gender age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness_2
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

*simple model.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain_2
  /METHOD=ENTER age gender
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE COOK RESID.

*Compute resid squared.
COMPUTE res_simp_sq=RES_1*RES_1.
EXECUTE.

*Breush-Pagan test.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT res_simp_sq
  /METHOD=ENTER age gender
  /RESIDUALS DURBIN.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID COO_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: COO_1=col(source(s), name("COO_1"))
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("Cook's Distance"))
  GUIDE: text.title(label("Simple Scatter of Cook's Distance by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*COO_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain_2 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain_2=col(source(s), name("pain_2"), unit.category())
  GUIDE: axis(dim(1), label("Age"))
  GUIDE: axis(dim(2), label("Pain level"))
  GUIDE: text.title(label("Simple Scatter of Pain level by Age"))
  ELEMENT: point(position(age*pain_2))
END GPL.

* Scatterplot age vs pain.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain_2 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain_2=col(source(s), name("pain_2"))
  GUIDE: axis(dim(1), label("Age"))
  GUIDE: axis(dim(2), label("Pain level"))
  GUIDE: text.title(label("Simple Scatter of Pain level by Age"))
  ELEMENT: point(position(age*pain_2))
END GPL.

*Model comparison.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain_2
  /METHOD=ENTER age gender
  /METHOD=ENTER STAI_trait pain_cat cortisol_serum mindfulness_2
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE COOK RESID.

*Create resid squared.
COMPUTE res_cpx_sq=RES_2*RES_2.
EXECUTE.

*Breush-Pagan test.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT res_cpx_sq
  /METHOD=ENTER age gender STAI_trait pain_cat cortisol_serum mindfulness_2
  /RESIDUALS DURBIN.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID COO_4 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: COO_4=col(source(s), name("COO_4"))
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("Cook's Distance"))
  GUIDE: text.title(label("Simple Scatter of Cook's Distance by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*COO_4))
END GPL.

* Scatterplot pain_cat vs pain.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain_2 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain_2=col(source(s), name("pain_2"))
  GUIDE: axis(dim(1), label("Pain catastrophizing"))
  GUIDE: axis(dim(2), label("Pain level"))
  GUIDE: text.title(label("Simple Scatter of Pain level by Pain catastrophizing"))
  ELEMENT: point(position(pain_cat*pain_2))
END GPL.

* Scatterplot cortisol vs pain.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain_2 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain_2=col(source(s), name("pain_2"))
  GUIDE: axis(dim(1), label("Cortisol level (serum)"))
  GUIDE: axis(dim(2), label("Pain level"))
  GUIDE: text.title(label("Simple Scatter of Pain level by Cortisol level (serum)"))
  ELEMENT: point(position(cortisol_serum*pain_2))
END GPL.

* Scatterplot minfulness vs pain.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness_2 pain_2 MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness_2=col(source(s), name("mindfulness_2"))
  DATA: pain_2=col(source(s), name("pain_2"))
  GUIDE: axis(dim(1), label("MAAS"))
  GUIDE: axis(dim(2), label("Pain level"))
  GUIDE: text.title(label("Simple Scatter of Pain level by MAAS"))
  ELEMENT: point(position(mindfulness_2*pain_2))
END GPL.

* Scatterplot STAI vs pain.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait pain_2 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: pain_2=col(source(s), name("pain_2"))
  GUIDE: axis(dim(1), label("STAI"))
  GUIDE: axis(dim(2), label("Pain level"))
  GUIDE: text.title(label("Simple Scatter of Pain level by STAI"))
  ELEMENT: point(position(STAI_trait*pain_2))
END GPL.

*Compare simple_2 and complex_2.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain_2
  /METHOD=ENTER pain_cat cortisol_serum
  /METHOD=ENTER age
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).
