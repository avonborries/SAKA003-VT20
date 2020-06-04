* Encoding: UTF-8.

*Creating summies for class.
DATASET ACTIVATE DataSet1.
SPSSINC CREATE DUMMIES VARIABLE=Pclass 
ROOTNAME1=class2
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

*Recoding sex into gender.
RECODE Sex ('female'=1) ('male'=0) INTO Gender. 
EXECUTE. 

*Exploring the data.
DESCRIPTIVES VARIABLES=Survived Age Gender SibSp Parch Pclass
  /STATISTICS=MEAN STDDEV MIN MAX.

FREQUENCIES VARIABLES=Gender

FREQUENCIES VARIABLES=Age SibSp Parch
  /HISTOGRAM
  /ORDER=ANALYSIS.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Age MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Age=col(source(s), name("Age"))
  GUIDE: axis(dim(1), label("Age"))
  GUIDE: axis(dim(2), label("Frequency"))
  GUIDE: text.title(label("Simple Histogram of Age"))
  ELEMENT: interval(position(summary.count(bin.rect(Age))), shape.interior(shape.square))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived Age MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: Age=col(source(s), name("Age"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Age"))
  GUIDE: text.title(label("Simple Boxplot of Age by Survived"))
  SCALE: cat(dim(1), include("0", "1"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*Age)), label(id))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived SibSp MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: SibSp=col(source(s), name("SibSp"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("SibSp"))
  GUIDE: text.title(label("Simple Boxplot of SibSp by Survived"))
  SCALE: cat(dim(1), include("0", "1"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*SibSp)), label(id))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived Parch MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: Parch=col(source(s), name("Parch"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Parch"))
  GUIDE: text.title(label("Simple Boxplot of Parch by Survived"))
  SCALE: cat(dim(1), include("0", "1"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*Parch)), label(id))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Sex COUNT()[name="COUNT"] Survived MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Sex=col(source(s), name("Sex"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Sex"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Sex by Survived"))
  SCALE: linear(dim(2), include(0))
  SCALE: cat(aesthetic(aesthetic.color.interior), include("0", "1"))
  ELEMENT: interval.stack(position(Sex*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Pclass COUNT()[name="COUNT"] Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Pclass"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Pclass by Survived"))
  SCALE: linear(dim(2), include(0))
  SCALE: cat(aesthetic(aesthetic.color.interior), include("0", "1"))
  ELEMENT: interval.stack(position(Pclass*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

*First logistic analysis.
LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age Gender SibSp Parch Second_class Third_class 
  /SAVE=COOK
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).

*Second logistic analysis.
LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age Gender SibSp Second_class Third_class 
  /SAVE=COOK
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).

*Logistic regression analysis through multinomial regression procedure.
NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Age Gender SibSp Second_class Third_class
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC
  /SAVE PREDCAT ACPROB.

*Recoding Parch into a dummy variable.
RECODE Parch (0=0) (ELSE=1) INTO Parch2.
EXECUTE.

*Third logistic analysis.
LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age Gender SibSp Second_class Third_class Parch2 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).

*Recoding Parch into categorical variable.
RECODE Parch (0=0) (1=1) (2=2) (ELSE=3) INTO parch3.
EXECUTE.

*Creating dummies from Parch categorical.
SPSSINC CREATE DUMMIES VARIABLE=parch3 
ROOTNAME1=parch3 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

*Fouth logistic analysis.
LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age Gender SibSp Second_class Third_class parch3_1 parch3_3 parch3_4 
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).

