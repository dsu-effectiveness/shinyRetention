#' Get goal data
#'
#' Reads goal data from temporary CSV file.
#' To be replaced by call to database.
get_goal_data = function() {
  goal_data = readr::read_csv("inst/app/fake_data/tab_1_goals.csv",
                              show_col_types = FALSE,
                              progress = FALSE)
  return(goal_data)
}

#' Get summarised retention data
#'
#' Reads summarised retention data from temporary CSV file.
#' To be replaced by call to database.
get_summarised_retention_data = function(retention_df) {
  input_metric <- 'spring_returned'
  input_group <- 'population'
  summarized_retention_df <- retention_df %>%
    calculate_headcount(input_metric, input_group) %>%
    calculate_return_rate(input_metric) %>%
    dplyr::mutate(metric='Fall to Spring',
                  year=cohort)

  #summarised_data = readr::read_csv("inst/app/fake_data/tab_1_df.csv",
  #                                  show_col_types = FALSE,
  #                                  progress = FALSE)

  return(summarized_retention_df)
}

#' Get retention data
#'
#' Reads retention data from RStudio Connect pin.
#' Requires environment variable RETENTION_VERSION
#' defined as either "private" or "public".
get_retention_data = function(method="from_sql") {

  if (method == "from_sql") {
    ## 1st option
    retention_data_from_sql <- utHelpR::get_data_from_sql_file("retention.sql", dsn="edify", context="shiny") %>%
      dplyr::mutate( cohort = as.numeric(cohort) )
    retention_data <- retention_data_from_sql
  }
  else if (method == "from_csv") {
    ## 2nd option
    retention_data_from_csv <- readr::read_csv("inst/app/fake_data/tabs_3_and_4.csv",
                                      show_col_types = FALSE,
                                      progress = FALSE)
    retention_data <- retention_data_from_csv

  }
  else if (method == "from_pin") {
    ## 3rd option
    retention_version <- get_retention_version()
    pin_user <- get_pin_user()
    board_rsc <- pins::board_rsconnect()
    retention_path <- glue::glue("{pin_user}/{retention_version}_retention")
    retention_data_from_pin <- pins::pin_read(board_rsc, retention_path)
    retention_data <- retention_data_from_pin
  }
  else {
    stop("Method for gathering retention data is not defined.")
  }

  return(retention_data)
}

#' Get user for pinned data
#'
#' Read environment variable which sets
#' which RStudio Connect account pinned data is read from
get_pin_user = function() {
  pin_user = Sys.getenv("PIN_USER")
  if (pin_user == "") {
    cli::cli_alert_warning("Ensure you have an environment variable called PIN_USER")
    cli::cli_alert_warning("PIN_USER should be the user where data pins are uploaded")
    stop("Fix env variable PIN_USER and try again")
  }
  return(pin_user)
}

#' Get version of retention app
#'
#' Read environment variable which decides
#' whether to use the public or private version of
#' the retention data.
get_retention_version = function() {
  retention_version = Sys.getenv("RETENTION_VERSION")
  valid_versions = c("public", "private")
  if (!(retention_version %in% valid_versions)) {
    cli::cli_alert_warning("Ensure you have an environment variable called RETENTION_VERSION")
    cli::cli_alert_warning("RETENTION_VERSION should be either 'private' or 'public'")
    stop("Fix env variable RETENTION_VERSION and try again")
  }
  return(retention_version)
}
