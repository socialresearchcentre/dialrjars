library(xml2)
library(dplyr)

update_libphonenumber <- function(jar_name = "libphonenumber", pkg_location = ".") {
  message("dialrjars: checking for latest version of '", jar_name, "' jar")
  jar_file <- list.files(file.path(pkg_location, "inst/java"), paste0("^", jar_name, "-(.*).jar$"))

  current <- sub(paste0("^", jar_name, "-(.*).jar$"), "\\1", jar_file)
  if (length(current) == 0) current <- "none"

  latest <- read_xml(paste0("http://repo1.maven.org/maven2/com/googlecode/libphonenumber/", jar_name, "/maven-metadata.xml")) %>%
    xml_find_first("//latest") %>%
    xml_text

  tryCatch({
    if (current != latest) {
      message("dialrjars: updating '", jar_name, "' jar from version ", current, " to ", latest)
      download.file(paste0("http://repo1.maven.org/maven2/com/googlecode/libphonenumber/", jar_name, "/",
                           latest, "/", jar_name, "-", latest, ".jar"),
                    paste0("inst/java/", jar_name, "-", latest, ".jar"),
                    quiet = TRUE, mode = "wb")

      file.remove(file.path(pkg_location, "inst/java", jar_file))
    }
    message("dialrjars: '", jar_name, "' jar is up to date!")
  },
  error = function(e) { message("dialrjars: '", jar_name, "' jar update failed, continuing with version ", current) })

  if (grepl("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", latest))
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

  update_libphonenumber("carrier")
  update_libphonenumber("geocoder")
  update_libphonenumber("prefixmapper")

  message("dialrjars: updating version in DESCRIPTION to ", latest)
  desc::desc_set_version(latest)

  message("dialrjars: updating NEWS.md for version ", latest)
  usethis:::use_news_heading(paste0(latest,
                                    "\n\n* Update to libphonenumber version ",
                                    latest))

  if (usethis::ui_yeah("Commit changes to git?")) {
    message("dialrjars: committing changes to git")
    git2r::add(path = "inst/java")
    git2r::add(path = "DESCRIPTION")
    git2r::add(path = "NEWS.md")
    git2r::commit(message = paste0("Update libphonenumber to version ", latest))
  }

  if (usethis::ui_yeah("Push to github?")) {
    message("dialrjars: pushing to github")
    tryCatch(git2r::push(),
             error = function(e) {
               warning("dialrjars: failed to push to github with error:\n  ", e, call. = FALSE)
             })
  }

  invisible(latest)
}

update_dialrjars()
