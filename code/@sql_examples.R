dbGetQuery(con, "SELECT nspname FROM pg_catalog.pg_namespace") #Check schemas
DBI::dbListObjects(con, DBI::Id(schema = 'basin_boundaries')) #Check tables of a schema