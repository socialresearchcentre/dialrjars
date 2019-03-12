library(xml2)

#' @import xml2
.update_libphonenumber <- function() {
  message("dialr: checking for latest version of libphonenumber")
  jar_file <- list.files(system.file("java", package = "dialr"), ".*.jar$")

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
                    paste0(system.file("java", package = "dialr"), "/libphonenumber-", latest, ".jar"),
                    quiet = TRUE)

      invisible(file.remove(system.file("java", jar_file, package = "dialr")))
    }
    message("dialr: up to date!")
  },
  error = function(e) { message("dialr: libphonenumber update failed, continuing with version ", current) })
}

.update_libphonenumber()
