#Create artificial river data sets for playtesting 

source('./source/libs.R')
source('./source/graphics.R')

#We shall start with no branches

#type 1 are straight rivers 
very_straight_river <- data.frame(lon = c(-1, 0, 1, 2, 3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 11, 12),
                            lat = c(5, 4, 3, 3, 2, 2, 2, 1, 0, 0, 1, 1, 0, 0, 1, 0))                          

#type 2 are curved rivers 
horse_shoe_river <- data.frame(lon = c(3, 2, 1, 2, 3, 4, 5, 6, 6, 5, 4, 3, 2, 2, 1, 0),
                            lat = c(5, 4, 3, 3, 2, 2, 2, 1, 0, 0, 1, 1, 0, 0, 1, 0))

#type 3 are the rivers with meanders
snake_river <- data.frame(lon = c(3, 2, 1, 2, 3, 4, 5, 6, 6, 5, 4, 3, 2, 2, 1, 0),
                          lat = c(5, 4, 3, 3, 2, 2, 2, 1, 0, 0, 1, 1, 0, 0, 1, 0))

plot(very_straight_river, type = 'b')
plot(horse_show_river, type = 'b')
plot(snake_river, type = 'b')

