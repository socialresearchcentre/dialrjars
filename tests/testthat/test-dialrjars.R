context("load jars")

library(rJava)
.jpackage("dialrjars", lib.loc = .libPaths())

test_that("package jars load successfully", {
  phone_util <- .jcall("com/google/i18n/phonenumbers/PhoneNumberUtil",
                       "Lcom/google/i18n/phonenumbers/PhoneNumberUtil;",
                       "getInstance")

  expect_equal(.jclass(phone_util),
               "com.google.i18n.phonenumbers.PhoneNumberUtil")
})
