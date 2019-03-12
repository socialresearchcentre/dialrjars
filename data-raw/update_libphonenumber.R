library(xml2)
library(dplyr)
library(stringr)

update_libphonenumber <- function(pkg_location = ".") {
  message("dialr: checking for latest version of libphonenumber")
  jar_file <- list.files(file.path(pkg_location, "inst/java"), ".*.jar$")

  current <- sub("^libphonenumber-(.*).jar$", "\\1", jar_file)
  if (length(current) == 0) current <- "none"

  latest <- read_xml("http://repo1.maven.org/maven2/com/googlecode/libphonenumber/libphonenumber/maven-metadata.xml") %>%
    xml_find_first("//latest") %>%
    xml_text

  tryCatch({
    if (current != latest) {
      message("dialr: updating libphonenumber from version ", current, " to ", latest)
      download.file(paste0("http://repo1.maven.org/maven2/com/googlecode/libphonenumber/libphonenumber/",
                           latest, "/libphonenumber-", latest, ".jar"),
                    paste0("inst/java/libphonenumber-", latest, ".jar"),
                    quiet = TRUE)

      file.remove(file.path(pkg_location, "inst/java", jar_file))
    }
    message("dialr: up to date!")
  },
  error = function(e) { message("dialr: libphonenumber update failed, continuing with version ", current) })

  if (str_detect(latest, "[0-9]+\\.[0-9]+\\.[0-9]+"))
    latest
  else
    current

}

update_pkg_version <- function(vers, pkg_location = "."){
  desc <- readLines(file.path(pkg_location, "DESCRIPTION"))
  desc[str_detect(desc, "^Version:")] <- paste0("Version: ", vers)
  writeLines(desc, file.path(pkg_location, "DESCRIPTION"))

  return(vers)
}

vers <- update_libphonenumber()
update_pkg_version(vers)
devtools::build(binary = TRUE, args = c('--preclean'))
