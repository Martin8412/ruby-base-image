load("@rules_foreign_cc//foreign_cc:configure.bzl", "configure_make")

configure_make(
    name = "ruby",
    configure_options = [
        "--enable-yjit",
        "--with-gmp",
        "--with-jemalloc",
        "--with-static-linked-ext",
    ],
    lib_source = "@ruby_src//:all_srcs",
)
