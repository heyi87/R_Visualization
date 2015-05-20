scale_year <- function() {
  return(
    scale_x_continuous(
      name = "Year",
      # using 1980 will result in gap
      limits = c(1969, 1984.917 ),
      expand = c(0, 0),
      # still want 1980 at end of scale
      breaks = c(seq(1969, 1984, 1), 1984.917 ),
      labels = function(x) {ceiling(x)}
    )
  )
}

scale_deaths <- function() {
  return (
    scale_y_continuous(
      name = "Deaths in Thousands",
      # set nice limits and breaks
      limits = c(0, 2000),
      expand = c(0, 0),
      breaks = seq(0, 2000, 500),
      # reduce label space required
      labels = function(x) {paste0(x / 1000, 'k')}
    )    
  )
}

theme_legend <- function() {
  return(
    theme(
      legend.direction = "horizontal",
      legend.position = c(1, 1),
      legend.justification = c(1, 1),
      legend.title = element_blank(),
      legend.background = element_blank(),
      legend.key = element_blank()
    )
  )
}

theme_guide <- function() {
  options = list(size = 2)
  
  return(
    guides(
      colour = guide_legend(
        "year", 
        override.aes = options
      )
    )
  )
}

count <- 1
fancy_label <- function(x) {
  count <<- count + 1
  if (count %% 2 == 0) { return(x) }
  else { return(c("", x[2:12])) }
}

scale_months <- function() {
  return(
    scale_x_discrete(
      name = "Month",
      expand = c(0, 0),
      # this is for faceting,
      # can be removed otherwise
      labels = fancy_label
    )
  )
}