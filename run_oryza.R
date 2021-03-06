
# function(dir_run, dir_files, region, cultivar, climate_scenarios = climate$climate_scenarios, input_dates = climate$input_dates, location, select_day = day){


run_oryza <- function(dir_run, dir_files, region, cultivar, climate_scenarios, input_dates, location, select_day){
  
  lat <- location$lat
  long <- location$elev
  elev <- location$elev
  
  ## make id run 
  
  id_run <- make_id_run(paste0(dir_run, 'Temporal/'), region, cultivar, select_day)
  
  
  make_mult_weather(climate_scenarios, id_run, filename, long, lat, elev)
  make_control(id_run)   ## mirar la funcion para cambiar las especificaciones
  
  
  ## por ahora parece ser que se puede tener todo el vector
  
  PDATE <- input_dates$PDATE[select_day]
  SDATE <- input_dates$SDATE[select_day]
  IYEAR <- input_dates$IYEAR[select_day]
  ISTN <- 1:length(climate_scenarios)
  DATE <- input_dates$DATE[select_day]
  
  ## esta parte se puede integrar antes de a�adir los archivos que necesita oryza y que no depende de una funcion
  parameters_reruns <- settins_reruns(region, PDATE, SDATE, IYEAR, ISTN, id_run)
  
  make_reruns(parameters_reruns, id_run)
  files_oryza(dir_oryza, id_run)
  id_soil <- add_exp_cul(dir_files, region, id_run)  ## controla los parametros por region y retorna el id del suelo
  execute_oryza(id_run)
  
  ## extraer summary
  
  op_dat <- read_op(id_run) %>%
    mutate(yield_14 = WRR14,
           prec_acu = RAINCUM,
           t_max_acu = TMAXC,
           t_min_acu = TMINC,
           bio_acu = WAGT)
  
  
  yield <- calc_desc(op_dat, 'yield_14') %>%
    tidy_descriptive(region, id_soil, cultivar, DATE, DATE)
  
  prec_acu <- calc_desc(op_dat, 'prec_acu') %>%
    tidy_descriptive(region, id_soil, cultivar, DATE, DATE)
  
  t_max_acu <- calc_desc(op_dat, 't_max_acu') %>%
    tidy_descriptive(region, id_soil, cultivar, DATE, DATE)
  
  t_min_acu <- calc_desc(op_dat, 't_min_acu') %>%
    tidy_descriptive(region, id_soil, cultivar, DATE, DATE)
  
  bio_acu <- calc_desc(op_dat, ' bio_acu') %>%
    tidy_descriptive(region, id_soil, cultivar, DATE, DATE)
  
  summary_stats <- dplyr::bind_rows(list(yield, 
                                         prec_acu,
                                         t_max_acu,
                                         t_min_acu,
                                         bio_acu))
  setwd(dir_run)
  return(summary_stats)
  
  
  
}
