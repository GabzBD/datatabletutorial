require(data.table)
data(mtcars)
mtcars<-as.data.table(mtcars,keep.rownames=T)
names(mtcars)[1]<-"Brands"

table(mtcars$wt)

### common task, discretize a column. possible?, by another variable?
mtcars[,lapply(mtcars[,3:5],function(x)
  {ifelse(x>3 & x<6,"yes",ifelse(x>=6 & x<100,NA,"no"))}),by=gear]

mtcars[,c("cyl1","disp1","hp1"):=lapply(mtcars[,3:5],function(x)
{ifelse(x>3 & x<6,"yes",ifelse(x>=6 & x<100,NA,"no"))})]

## count NA's per carb
mtcars[,c("cyl1","disp1","hp1")]
mtcars[,lapply(mtcars[,3:5],function(x){sum(is.na(x))}),by=gear]