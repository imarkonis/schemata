source('./source/libs.R')
source('./source/graphics.R')

#type 1 are linear rivers with no branches
dummy_river_1 <- data.frame(lon = c(-1, 0, 1, 2, 3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 11, 12),
                            lat = c(5, 4, 3, 3, 2, 2, 2, 1, 0, 0, 1, 1, 0, 0, 1, 0))                          

#type 2 are curved rivers with no branches
dummy_river_2 <- data.frame(lon = c(3, 2, 1, 2, 3, 4, 5, 6, 6, 5, 4, 3, 2, 2, 1, 0),
                            lat = c(5, 4, 3, 3, 2, 2, 2, 1, 0, 0, 1, 1, 0, 0, 1, 0))

plot(dummy_river_1, type = 'b')
plot(dummy_river_2, type = 'b')

