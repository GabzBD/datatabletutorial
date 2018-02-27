### EFFICIENT RESHAPING


DT = fread("melt_default.csv")
DT
#    family_id age_mother dob_child1 dob_child2 dob_child3
# 1:         1         30 1998-11-26 2000-01-29         NA
# 2:         2         27 1996-06-22         NA         NA
# 3:         3         26 2002-07-11 2004-04-05 2007-09-02
# 4:         4         32 2004-10-10 2009-08-27 2012-07-21
# 5:         5         29 2000-12-05 2005-02-28         NA
## dob stands for date of birth.

DT.m1 = melt(DT, id.vars = c("family_id", "age_mother"),
             measure.vars = c("dob_child1", "dob_child2", "dob_child3"))
DT.m1 # reshape 2 is used by data.table
DT.m1 = melt(DT, measure.vars = c("dob_child1", "dob_child2", "dob_child3"),
             variable.name = "child", value.name = "dob")
DT.m1
#By default, when one of id.vars or measure.vars is missing,
#the rest of the columns are automatically assigned to the missing argument.

dcast(DT.m1, family_id + age_mother ~ child, value.var = "dob")
#    family_id age_mother dob_child1 dob_child2 dob_child3
# 1:         1         30 1998-11-26 2000-01-29         NA
# 2:         2         27 1996-06-22         NA         NA
# 3:         3         26 2002-07-11 2004-04-05 2007-09-02
# 4:         4         32 2004-10-10 2009-08-27 2012-07-21
# 5:         5         29 2000-12-05 2005-02-28         NA

#You can also pass a function to aggregate by in dcast with the 
#argument fun.aggregate. This is particularly essential when the 
#formula provided does not identify single observation for each cell.

dcast(DT.m1, family_id ~ age_mother, fun.agg = function(x) sum(!is.na(x)), value.var = "dob")
dcast(DT.m1, family_id ~ ., fun.agg = function(x) sum(!is.na(x)), value.var = "dob")


### extensions beyond the reshape 2 applications
DT = fread("melt_enhanced.csv")
DT
### we would melt dob and gender simultaneously, without stacking them both first

colA = paste("dob_child", 1:3, sep = "")
colB = paste("gender_child", 1:3, sep = "")
DT.m2 = melt(DT, measure = list(colA, colB), value.name = c("dob", "gender"))
DT.m2 # note, we lost the child number, which we could add later...

### enhanced dcast
## new 'cast' functionality - multiple value.vars
DT.c2 = dcast(DT.m2, family_id + age_mother ~ variable, value.var = c("dob", "gender"))
DT.c2


## NEW FEATURE - multiple value.var and multiple fun.aggregate
dt = data.table(x=sample(5,20,TRUE), y=sample(2,20,TRUE), 
                z=sample(letters[1:2], 20,TRUE), d1 = runif(20), d2=1L)
# multiple value.var
dcast(dt, x + y ~ z, fun=sum, value.var=c("d1","d2"))
dcast(dt, x + y ~ z, fun=list(sum, mean), value.var="d1")

