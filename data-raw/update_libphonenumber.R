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
                    quiet = TRUE, mode = "wb")

      file.remove(file.path(pkg_location, "inst/java", jar_file))
    }
    message("dialrjars: libphonenumber up to date!")
  },
  error = function(e) { message("dialrjars: libphonenumber update failed, continuing with version ", current) })

  if (str_detect(latest, "^[0-9]+\\.[0-9]+\\.[0-9]+$"))
    latest
  else
    current

}

update_dialrjars <- function() {
  current <- desc::desc_get_version()

  message("dialrjars: checking for package updates for version ", current)
  latest <- update_libphonenumber()

  if (current == latest) {
    message("dialrjars: no changes required, exiting...")
    return(invisible(latest))
  }

  message("dialrjars: updating version in DESCRIPTION to ", latest)
  desc::desc_set_version(latest)

  message("dialrjars: updating NEWS.md for version ", latest)
  usethis:::use_news_heading(paste0(latest,
                                    "\n\n* Update to libphonenumber version ",
                                    latest))

  message("dialrjars: committing changes to git")
  git2r::add(path = "inst/java")
  git2r::add(path = "DESCRIPTION")
  git2r::add(path = "NEWS.md")
  git2r::commit(message = paste0("Update libphonenumber to version ", latest))

  message("dialrjars: pushing to github")
  tryCatch(git2r::push(),
           error = function(e) {
             warning("dialrjars: failed to push to github with error:\n  ", e, call. = FALSE)
           })

  message("dialrjars: building new binary")
  devtools::build(binary = TRUE, args = c('--preclean'))

  invisible(latest)
}

update_dialrjars()
