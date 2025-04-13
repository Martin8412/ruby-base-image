load("@aspect_bazel_lib//lib:tar.bzl", "tar")
load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_distroless//distroless:defs.bzl", "cacerts", "group", "os_release", "passwd")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_push")

COMPATIBLE_WITH = select({
    "@platforms//cpu:x86_64": ["@platforms//cpu:x86_64"],
    "@platforms//cpu:arm64": ["@platforms//cpu:arm64"],
}) + [
    "@platforms//os:linux",
]

passwd(
    name = "passwd",
    entries = [
        {
            "uid": 0,
            "gid": 0,
            "home": "/root",
            "shell": "/bin/bash",
            "username": "root",
        },
        {
            "uid": 100,
            "gid": 65534,
            "home": "/home/_apt",
            "shell": "/usr/sbin/nologin",
            "username": "_apt",
        },
        {
            "uid": 1000,
            "gid": 1000,
            "home": "/home/user",
            "shell": "/usr/bin/bash",
            "username": "user",
        },
    ],
)

group(
    name = "group",
    entries = [
        {
            "name": "root",
            "gid": 0,
        },
        {
            "name": "_apt",
            "gid": 65534,
        },
        {
            "name": "user",
            "gid": 1000,
        },
    ],
)

tar(
    name = "sh",
    mtree = [
        # needed as dpkg assumes sh is installed in a typical debian installation.
        "./bin/sh type=link link=/bin/bash",
    ],
)

cacerts(
    name = "cacerts",
    package = "@bookworm//ca-certificates:data",
    target_compatible_with = COMPATIBLE_WITH,
)

os_release(
    name = "os_release",
    content = {
        "PRETTY_NAME": "Ruby image",
        "VERSION": "Debian GNU/Linux",
    },
)

oci_image(
    name = "image",
    architecture = select({
        "@platforms//cpu:arm64": "arm64",
        "@platforms//cpu:x86_64": "amd64",
    }),
    env = {
        # Required to use the SSL certs from `cacerts()`
        "SSL_CERT_FILE": "/etc/ssl/certs/ca-certificates.crt",
    },
    os = "linux",
    # NOTE: this is needed because, otherwise, bazel test //... fails, even
    # when container_structure_test already has target_compatible_with.
    # See 136
    target_compatible_with = COMPATIBLE_WITH,
    tars = [
        # This target contains all the installed packages.
        "@bookworm//:flat",
        ":sh",
        ":passwd",
        ":group",
        ":cacerts",
        ":os_release",
    ],
)

oci_push(
    name = "push",
    image = ":image",
    remote_tags = [
        "distrolesstest",
    ],
    repository = "martin8412/ruby_base_image",
)

platform(
    name = "linux_arm64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:arm64",
    ],
)

platform(
    name = "linux_amd64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

platform_transition_filegroup(
    name = "image_platform",
    srcs = [":image"],
    target_platform = select({
        "@platforms//cpu:arm64": ":linux_arm64",
        "@platforms//cpu:x86_64": ":linux_amd64",
    }),
)
