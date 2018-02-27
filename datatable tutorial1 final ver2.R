### from datatable tutorial1 final.R
mydata<-flights
nrow(mydata)
#[1] 253316
ncol(mydata)
#[1] 17
names(mydata)
#[1] "year"      "month"     "day"       "dep_time"  "dep_delay" "arr_time"  "arr_delay"

dat1 = mydata[ , origin] # returns a vector
dat1
dat1 = mydata[ , .(origin)] # returns a data.table
dat1
dat1 = mydata[, c("origin"), with=FALSE]
dat1

dat3 = mydata[, .(origin, year, month, hour)]
dat3 = mydata[, c("origin", "year", "month", "hour")] #works too
dat4 = mydata[, c(2:4), with=FALSE]
dat4 = mydata[, c(2:4)] 

dat5 = mydata[, !c("origin"), with=FALSE]
dat5 = mydata[, !c("origin", "year", "month", "hour")]

dat7 = mydata[,names(mydata) %like% "dep", with=FALSE]
## %like% is like grepl, returns logical vector of length names(mydata)

## Renaming
setnames(mydata, c("dest","origin"), c("Destination", "origin.of.flight"))

## Subsetting/Filtering
dat9 = mydata[origin %in% c("JFK", "LGA")]
dat11 = mydata[origin == "JFK" & carrier == "AA"]

# for best results, use key 
# Indexing (Set Keys)
setkey(mydata, origin)

data12 = mydata[c("JFK", "LGA")]# since origin is ur key, us can subset directly
data12
mydata<-flights
system.time(mydata[origin %in% c("JFK", "LGA")])
setkey(mydata, origin)
system.time(mydata[c("JFK", "LGA")])
#user  system elapsed 
#0.010   0.001   0.010 
system.time(mydata %>% filter(origin %in% c("JFK", "LGA")))
#user  system elapsed 
#0.050   0.002   0.053 

key(mydata)

#Sorting
mydata03 = setorder(mydata, origin, -carrier) #origin falling

## adding columns
mydata002 = mydata[, c("dep_sch","arr_sch"):=list(dep_time - dep_delay, arr_time - arr_delay)]


## if-else condition
mydata[, flag:= 1*(min < 50)]
mydata[, flag:= ifelse(min < 50, 1,0)]


## Summarise or Aggregate
mydata[, dep_sch:=dep_time - dep_delay][,.(dep_time,dep_delay,dep_sch)]
# above is essential pipes

mydata[, .(mean = mean(arr_delay, na.rm = TRUE), #the key of aggregate is .()
           median = median(arr_delay, na.rm = TRUE),
           min = min(arr_delay, na.rm = TRUE),
           max = max(arr_delay, na.rm = TRUE))]

mydata[, .(mean(arr_delay), mean(dep_delay))]
mydata[, lapply(.SD, mean), .SDcols = c("arr_delay", "dep_delay")]
mydata[, lapply(.SD, mean)]

mydata[, sapply(.SD, function(x) c(mean=mean(x), median=median(x))),
       .SDcols = c("arr_delay", "dep_delay")]

## Group by operations
mydata[, .(mean_arr_delay = mean(arr_delay, na.rm = TRUE)), by = origin]

mydata[, .(mean_arr_delay = mean(arr_delay, na.rm = TRUE)), keyby = origin]

mydata[, lapply(.SD, mean, na.rm = TRUE), .SDcols = c("arr_delay", "dep_delay"), by = origin]

## remove duplicates
setkey(mydata, "carrier")
unique(mydata)

## extract values within group
mydata[, .SD[.N], by=carrier] #last value
mydata[, .SD[1], by=carrier] #fist value

## Window functions, frank Rank over partition
mydata[, rank:=frank(-distance,ties.method = "min"), by=carrier]
#we are calculating rank of variable 'distance' by 'carrier'. 

dat = mydata[, cum:=cumsum(distance), by=carrier] #cumulative
# nrows is preserved if we use :=

#Lead/Lag
DT <- data.table(A=1:5)
DT[ , X := shift(A, 1, type="lag")]
DT[ , Y := shift(A, 1, type="lead")]

## merging
(dt1 <- data.table(A = letters[rep(1:3, 2)], X = 1:6, key = "A"))
(dt2 <- data.table(A = letters[rep(2:4, 2)], Y = 6:1, key = "A"))
merge(dt1, dt2, by="A")
merge(dt1, dt2, by="A", all.x = TRUE)
merge(dt1, dt2, all=TRUE) ## all combinations present in combination of dt1 and dt2




c(27,25,20,17,11)
sum(c(27,25,20,17,11))
sum(c(27,25,20,17,11)^2)

sum(c(38,25,20,17)^2)
sum(c(52,20,17,11)^2)
