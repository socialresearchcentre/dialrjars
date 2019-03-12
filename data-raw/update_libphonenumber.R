library(xml2)
library(dplyr)
library(stringr)

update_libphonenumber <- function(pkg_location = ".") {
  message("dialrjars: checking for latest version of libphonenumber")
  jar_file <- list.files(file.path(pkg_location, "inst/java"), ".*.jar$")

  current <- sub("^libphonenumber-(.*).jar$", "\\1", jar_file)
  if (length(current) == 0) current <- "none"

  latest <- read_xml("http://repo1.maven.org/maven2/com/googlecode/libphonenumber/libphonenumber/maven-metadata.xml") %>%
    xml_find_first("//latest") %>%
    xml_text

  tryCatch({
    if (current != latest) {
      message("dialrjars: updating libphonenumber from version ", current, " to ", latest)
      download.file(paste0("http://repo1.maven.org/maven2/com/googlecode/libphonenumber/libphonenumber/",
                           latest, "/libphonenumber-", latest, ".jar"),
                    paste0("inst/java/libphonenumber-", latest, ".jar"),
                    quiet = TRUE)

      file.remove(file.path(pkg_location, "inst/java", jar_file))
    }
    message("dialrjars: libphonenumber up to date!")
  },
  error = function(e) { message("dialrjars: libphonenumber update failed, continuing with version ", current) })

  if (str_detect(latest, "[0-9]+\\.[0-9]+\\.[0-9]+"))
    latest
  else
    current

}

get_pkg_version <- function(pkg_location = ".") {
  desc <- readLines(file.path(pkg_location, "DESCRIPTION"))
  str_replace(desc[str_detect(desc, "^Version:")], "^Version:\\s*", "")
}

update_pkg_version <- function(vers, pkg_location = "."){
  desc <- readLines(file.path(pkg_location, "DESCRIPTION"))
  desc[str_detect(desc, "^Version:")] <- paste0("Version: ", vers)
  writeLines(desc, file.path(pkg_location, "DESCRIPTION"))

  invisible(vers)
}

update_dialrjars <- function() {
  current <- get_pkg_version()

  message("dialrjars: checking for package updates for version ", current)
  latest <- update_libphonenumber()

  if (current == latest) {
    message("dialrjars: no changes required, exiting...")
    return(invisible(latest))
  }

  message("dialrjars: updating version in DESCRIPTION to ", latest)
  update_pkg_version(latest)

  message("dialrjars: committing changes to git")
  git2r::add(path = "inst/java")
  git2r::add(path = "DESCRIPTION")
  git2r::commit(message = paste0("Update libphonenumber to version ", latest))

  message("dialrjars: building new binary")
  devtools::build(binary = TRUE, args = c('--preclean'))

  invisible(latest)
}

update_dialrjars()
