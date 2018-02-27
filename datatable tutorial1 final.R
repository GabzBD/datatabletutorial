###### Review data.table results

### use flight dataset
require(data.table)

namesflights <- fread("https://raw.githubusercontent.com/wiki/arunsrinivasan/flights/NYCflights14/flights14.csv")

DT = data.table(ID = c("b","b","b","a","a","c"), a = 1:6, b = 7:12, c = 13:18)
DT

############### selecting rows #####################
### first, select the flights originating from JFK

ans <- flights[origin=="JFK" ]
ans <- flights[origin=="JFK" & month==6]
ans <- flights[origin %in% "JFK"]

### first, select the flights originating from JFK and LGA
ans <- flights[origin %in% c("JFK","LGA")]
ans

#first 2 rows
flights[1:2]

### sorting? use order... to reverse it , use "-".
### na.last=T by default
ans<-flights[order(-origin)]
ans

### delete erase rows that fit a pattern
ans<-flights[origin!="JFK"]
ans
ans<-flights[!(origin %in% c("JFK","EWR"))]
ans

### notice, row operation requires you to copy it onto itself to work, which is 
### not true for column operations, which can create new content by "reference"

######### selecting columns ######################

### to return as a vector
flights[,origin]
# as datatable
ans <- flights[, list(arr_delay)]
flights[, .(arr_delay,year)]
## TIP: As long as j-expression returns a list, each element of 
## the list will be converted to a column in the resulting data.table. 
## This makes j quite powerful, as we will see shortly.

#Rename them
ans <- flights[, .(delay_arr = arr_delay, delay_dep = dep_delay)]

## Compute over all the obs
flights[, sum((arr_delay + dep_delay) < 0)]

## Select by names, as character
flights[, c("arr_delay", "dep_delay"), with = FALSE]
flights[, !c("arr_delay", "dep_delay"), with = FALSE]
flights[, -c("arr_delay", "dep_delay"), with = FALSE]

#what if you dont know the name, or its too long
# you can grep it, and use that to column
flights[,grep("origin",names(flights),val=T)] ### this wont work!
### because it evaluates the expression
head(flights[,names(flights)[1:3],with=F]) ### to get columns, use "with"


# returns all columns except year, month and day
ans<-flights[, -(year:day), with=FALSE]

### to return as data.table, use list or .()
flights[,.(origin)]
flights[month==1,list(origin,month)]



##### Lets see the power of this expressions in J 
### data.table uses columns as variables
flights[year==2014,plot(dep_time,dep_delay)] ### you can feed expressions, functions
flights[year==2014,density(dep_delay)]  ### gives you density data
flights[year==2014,min(dep_delay),by=origin] 



### to select both rows and column
flights[origin=="JFK","origin",with=F]
flights[origin=="JFK",.(origin)]


##### NEW to data.table vs dataframe
### i can do expressions on columns

flights[, sum((arr_delay + dep_delay)<0)] ### notice its not a datatable
flights[, .(sum((arr_delay + dep_delay)<0))] ## it is a datatable
flights[, .(sum((arr_delay + dep_delay)<0)),by=.(origin)]  # do it by groups

### get multiple statistics
flights[origin == "JFK" & month == 6L, 
        .(m_arr=mean(arr_delay), m_dep=mean(dep_delay))]
flights[origin == "JFK" & month == 6L, 
        c(m_arr=mean(arr_delay), m_dep=mean(dep_delay))] # as vector



## .N is a special in-built variable that holds the number of observations in the current group.

flights[,.N]

### Aggregations -----
ans <- flights[, .(.N), by = .(origin)]
ans ### N is number of obs per group
### by also accepts string column names vector
ans <- flights[, .(.N), by = "origin"]
ans
ans <- flights[, .(.N), by = c("origin","month")]
ans

### functions of other columns
ans <- flights[carrier == "AA",
               .(mean(arr_delay), mean(dep_delay)),
               by = .(origin, dest, month)]

### How can you program this, give a vector of column names to 
### find the mean? Solution: .SD
## .SD contains all columns except the grouping columns by default
DT[, lapply(.SD, mean), by = ID] # as long as .j gives a list of equal length,
## it will come out as a DT

### to subet SD further, use SDcols argument
flights[carrier == "AA",                       ## Only on trips with carrier "AA"
        lapply(.SD, mean),                     ## compute the mean
        by = .(origin, dest, month),           ## for every 'origin,dest,month'
        .SDcols = c("arr_delay", "dep_delay")] ## for just those specified in .SDcols
#      origin dest month  arr_delay  dep_delay

### use head and tail to get the first few rows
ans <- flights[, head(.SD, 2), by = month]
head(ans)

### .j is flexible: how to concatenate columns by group
DT[, .(val = c(a,b)), by = ID] # this is melt or "gather"
#     ID val
#  1:  b   1
#  2:  b   2
#  3:  b   3
#  4:  b   7
#  5:  b   8
DT[, .(val = list(c(a,b))), by = ID] # this is "true" contat
# 1:  b 1,2,3,7,8,9
# 2:  a  4, 5,10,11
# 3:  c        6,12



### by can accept expressions/ conditions
flights[, .N, .(dep_delay>0, arr_delay>0)]

### KEYBY: sorting by the ordering groups. ----- 
ans <- flights[carrier == "AA",
               .(mean(arr_delay), mean(dep_delay)),
               keyby = .(origin, dest, month)]
ans
## it also creates a key attribute


#### Chaining expressions ------
### allows you to skip creating intermediate steps

ans <- flights[carrier == "AA", .N, by = .(origin, dest)][order(origin, -dest)]
head(ans, 10)

ans <- flights[carrier == "AA", .N, by = .(origin, dest)
    ][order(origin, -dest)] ### chain them verticaly

head(ans, 10)

