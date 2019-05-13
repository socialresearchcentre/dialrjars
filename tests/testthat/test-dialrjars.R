context("load jars")

library(rJava)
.jpackage("dialrjars", lib.loc = .libPaths())

test_that("package jars load successfully", {
  phone_util <-
    .jcall("com/google/i18n/phonenumbers/PhoneNumberUtil",
           "Lcom/google/i18n/phonenumbers/PhoneNumberUtil;",
           "getInstance")

  expect_equal(.jclass(phone_util),
               "com.google.i18n.phonenumbers.PhoneNumberUtil")

  carrier_mapper <-
    .jcall("com/google/i18n/phonenumbers/PhoneNumberToCarrierMapper",
           "Lcom/google/i18n/phonenumbers/PhoneNumberToCarrierMapper;",
           "getInstance")

  expect_equal(.jclass(carrier_mapper),
               "com.google.i18n.phonenumbers.PhoneNumberToCarrierMapper")

  offline_geocoder <-
    .jcall("com/google/i18n/phonenumbers/geocoding/PhoneNumberOfflineGeocoder",
           "Lcom/google/i18n/phonenumbers/geocoding/PhoneNumberOfflineGeocoder;",
           "getInstance")

  expect_equal(.jclass(offline_geocoder),
               "com.google.i18n.phonenumbers.geocoding.PhoneNumberOfflineGeocoder")

  timezone_mapper <-
    .jcall("com/google/i18n/phonenumbers/PhoneNumberToTimeZonesMapper",
           "Lcom/google/i18n/phonenumbers/PhoneNumberToTimeZonesMapper;",
           "getInstance")

  expect_equal(.jclass(timezone_mapper),
               "com.google.i18n.phonenumbers.PhoneNumberToTimeZonesMapper")
})
