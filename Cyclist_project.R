
#set up library
library(tidyverse)
library(ggplot2)
library(lubridate)
library(janitor)

#import data
cy_202101<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202101-divvy-tripdata/202101-divvy-tripdata.csv")
cy_202102<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202102-divvy-tripdata/202102-divvy-tripdata.csv")
cy_202103<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202103-divvy-tripdata/202103-divvy-tripdata.csv")
cy_202104<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202104-divvy-tripdata/202104-divvy-tripdata.csv")
cy_202105<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202105-divvy-tripdata/202105-divvy-tripdata.csv")
cy_202106<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202106-divvy-tripdata/202106-divvy-tripdata.csv")
cy_202107<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202107-divvy-tripdata/202107-divvy-tripdata.csv")
cy_202108<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202108-divvy-tripdata/202108-divvy-tripdata.csv")
cy_202109<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202109-divvy-tripdata/202109-divvy-tripdata.csv")
cy_202110<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202110-divvy-tripdata/202110-divvy-tripdata.csv")
cy_202111<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202111-divvy-tripdata/202111-divvy-tripdata.csv")
cy_202112<- read_csv("BINUS/Google Data Analyst/Projek/Cyclist/202112-divvy-tripdata/202112-divvy-tripdata.csv")


#compare column names
colnames(cy_202101)
colnames(cy_202102)
colnames(cy_202103)
colnames(cy_202104)
colnames(cy_202105)
colnames(cy_202106)
colnames(cy_202107)
colnames(cy_202108)
colnames(cy_202109)
colnames(cy_202110)
colnames(cy_202111)
colnames(cy_202112)

str(cy_202102)

#compare data type
View(compare_df_cols(cy_202101,cy_202102,cy_202103,cy_202104,cy_202105,cy_202106,cy_202107,cy_202108,cy_202109,cy_202110,cy_202111,cy_202112))

View(cy_202101) 

View(cy_202101 %>% drop_na())

#untuk mengubah datatype apabila ada perbedaan
trips_2008 <- mutate(trips_2008, end_station_id = as.character(end_station_id), start_station_id = as.character(start_station_id))

#untuk menggabungkan semua data menjadi 1 data frame
cy_trips<-bind_rows(cy_202101,cy_202102,cy_202103,cy_202104,cy_202105,cy_202106,cy_202107,cy_202108,cy_202109,cy_202110,cy_202111,cy_202112)
View(cy_trips %>% drop_na())

#remove startlat,startlong,endlat,endlong
cy_trips<- cy_trips %>% select(-c(start_lat,start_lng,end_lat,end_lng))
View(cy_trips)

cy_trips %>% df(cy_trips).isnull
is.null(cy_trips).sum()

colnames(cy_trips)

# untuk melihat jumlah dataset dan kolom
dim(cy_trips)

summary(cy_trips)

#untuk membuat kolom baru untuk hari, bulan dan tahun
cy_trips$date <-as.Date(cy_trips$started_at) 
cy_trips$month <- format(as.Date(cy_trips$date),"%m")
cy_trips$day <- format(as.Date(cy_trips$date),"%d")
cy_trips$year <- format(as.Date(cy_trips$date),"%y")
cy_trips$day_of_week<- format(as.Date(cy_trips$date),"%A")

#untuk membuat kolom baru untuk durasi
cy_trips$ride_length<-difftime(cy_trips$ended_at,cy_trips$started_at)

cy_trips<-rename(cy_trips,ride_length=reide_length)
?strptime
?difftime

mean(cy_trips$ride_length)
median(cy_trips$ride_length)
max(cy_trips$ride_length)
min(cy_trips$ride_length)

#untuk menghilangkan data yang aneh (minus dari length) dan juga menghilangkan data yang null
cy_trips<-cy_trips %>% filter(ride_length>0) %>% drop_na()

#untuk melihat perbandingan mean dari ride length berdasarkan member(ada 2 cara, cara pertama menggunakan aggregate sedangakan cara kedua menggunakan group by lalu di summarize)
#cara pertama lebih simpel tapi lebih berat, cara kedua lebih capek tapi lebih cepat
aggregate(cy_trips$ride_length ~ cy_trips$member_casual,FUN = mean)

cy_trips %>% group_by(member_casual,day_of_week) %>% summarize(ride_length = mean(ride_length) )
cy_trips %>% group_by(member_casual) %>% summarize(ride_length = median(ride_length) )
cy_trips %>% group_by(member_casual) %>% summarize(ride_length = max(ride_length) )
cy_trips %>% group_by(member_casual) %>% summarize(ride_length = min(ride_length) )

aggregate(cy_trips$ride_length ~ cy_trips$member_casual + cy_trips$day_of_week, FUN = mean)

#untuk mengurutkan hari
cy_trips$day_of_week<- ordered(cy_trips$day_of_week,levels=c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))
?wday

#untuk melakukan visualisasi
cy_trips %>% 
  mutate(weekday = wday(started_at,label = TRUE)) %>% 
  group_by(member_casual,weekday) %>% 
  summarize(number_of_rides = n() , average_duration = mean(ride_length))  %>% 
  arrange(member_casual,weekday) %>% 
  ggplot(aes(x = weekday,y=number_of_rides,fill = member_casual))+ geom_col(position = "dodge")

cy_trips %>% 
  mutate(weekday = wday(started_at,label = TRUE)) %>% 
  group_by(member_casual,weekday) %>% 
  summarize(number_of_rides = n() , average_duration = mean(ride_length))  %>% 
  arrange(member_casual,weekday) %>% 
  ggplot(aes(x = weekday,y=average_duration,fill = member_casual))+ geom_col(position = "dodge")

cy_trips %>% 
  mutate(weekday = wday(started_at,label = TRUE)) %>% 
  group_by(member_casual,weekday) %>% 
  summarize(number_of_rides = n() , average_duration = mean(ride_length, rideable_type = rideable_type))  %>% 
  arrange(member_casual,weekday) %>% 
  ggplot(aes(x = rideable_type,y=number_of_rides,fill = member_casual))+ geom_col(position = "dodge")

View(cy_trips)

#untuk visualisasi berdasarkan member dengan pilihan sepeda
ggplot(data = cy_trips)+ geom_bar(mapping = aes(x=rideable_type,fill= rideable_type )) + facet_wrap(~member_casual)+ theme(axis.text.x = element_text(angle = 45))

count <- aggregate(cy_trips$ride_length ~ cy_trips$member_casual + cy_trips$day_of_week, FUN = mean)
count
write.csv(count,"result.csv")
?geom_col
