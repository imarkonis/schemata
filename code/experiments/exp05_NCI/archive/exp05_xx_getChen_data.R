source('code/source/libs.R')

library(DBI)
library(rgdal)

#SQLite database
con <- dbConnect(RSQLite::SQLite(), "data/Chen_et_al_long/LongPro.sql")
dbListTables(con)
dbListFields(con, "rivers")
dbListFields(con, "profiles")

# Get all columns but only first 50 entries
query_riv_info50 <- paste0("SELECT * FROM rivers limit 50")
riv_info <- st_read(con, query = query_riv_info50)


# Get unique koppen values
query_koppen <- paste0("SELECT DISTINCT koppen FROM rivers")
riv_info_koppen <- st_read(con, query = query_koppen)


#Get unique riverid
query_riv_id <- paste0("SELECT DISTINCT riverid FROM rivers limit 50")
riv_info_qu <- dbSendQuery(con, statement = query_riv_id)
fetch(riv_info_qu)


query_profile_info <- paste0("SELECT * FROM profiles limit 5")

profile_info <- dbSendQuery(con, statement = query_profile_info)

query_count_item <- paste0("SELECT uid 
                           FROM profiles
                           ORDER BY uid desc
                           LIMIT 1")

profile_n <- dbSendQuery(con, statement = query_count_item)
fetch(profile_n)

query_riv_id_profiles <- paste0("SELECT DISTINCT riverid FROM profiles")
profile_riv_id <- dbSendQuery(con, statement = query_riv_id_profiles)
fetch(profile_riv_id)


profile_riv_id_sel <- dbSendQuery(con, statement = "Select riverid from profiles limit 1")
riverid_sel <- fetch(profile_riv_id_sel)

profile_riv_all_sel <- dbSendQuery(con, statement = paste0("Select * from profiles where riverid = '",riverid_sel,"'"))
profile_riv_sel <- fetch(profile_riv_all_sel)

profile_riv_sel <- data.table(profile_riv_sel)

profile_riv_sel[, xend := length[which.min(length)]]
profile_riv_sel[, zend := elevation[which.min(length)]]


profile_riv_sel[, xbeg := length[which.max(length)]]
profile_riv_sel[, zbeg := elevation[which.max(length)]]

profile_riv_sel[,m := (zend-zbeg)/(xend-xbeg)]

profile_riv_sel[,zs := m*(length-xbeg) +zbeg]

profile_riv_sel[,NCI_seg := (elevation-zs)/(zbeg-zend)]
profile_riv_sel[, NCI:= median(NCI_seg)]


ggplot(profile_riv_sel)+
  geom_point(aes(x = length-xbeg, y = elevation))+
  geom_point(aes(x = length-xbeg, y = zs), color = "blue", pch = 4)

# need to assign pfaffstatter id
  