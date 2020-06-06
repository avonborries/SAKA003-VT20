* Encoding: UTF-8.
* Dataset A.

*Exploring data.
DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.

FREQUENCIES VARIABLES=sex
  /ORDER=ANALYSIS.

RECODE sex ('Male'=0) ('male'=0) ('female'=1) INTO gender.
EXECUTE.

DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness gender
  /STATISTICS=MEAN STDDEV MIN MAX.

FREQUENCIES VARIABLES=hospital
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness gender
  /STATISTICS=STDDEV MEAN MEDIAN
  /HISTOGRAM
  /ORDER=ANALYSIS.

* Scatterplot pain vs ID color by hospital.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID pain hospital MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by ID by hospital"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*pain), color.interior(hospital))
END GPL.

*Scatterplot pain (mean) vs hospital.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=hospital MEAN(pain)[name="MEAN_pain"] 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  DATA: MEAN_pain=col(source(s), name("MEAN_pain"))
  GUIDE: axis(dim(1), label("hospital"))
  GUIDE: axis(dim(2), label("Mean pain"))
  GUIDE: text.title(label("Simple Scatter Mean of pain by hospital"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(hospital*MEAN_pain))
END GPL. 

*Random intercept model.
DATASET ACTIVATE DataSet3.
MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness gender | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED RESID.

*Null model.
MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness gender
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=| SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED RESID.

*Dataset B.

RECODE sex ('male'=0) ('female'=1) INTO gender.
EXECUTE.

COMPUTE Pain_predict=3.799 - 0.0544*age + 0.001437*STAI_trait + 0.036885*pain_cat + 
    0.61001*cortisol_serum - 0.262441*mindfulness - 0.297545*gender.
EXECUTE.

COMPUTE TSS=(pain - 5.205)*(pain - 5.205).
EXECUTE.

COMPUTE RSS=(pain-Pain_predict)*(pain-Pain_predict).
EXECUTE.
