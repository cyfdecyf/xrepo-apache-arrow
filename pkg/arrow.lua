includes("common.lua")

add_requires("arrow", get_configs("arrow"))

local deps = {
    "thrift", "boost", "libevent", "openssl",
    "rapidjson", "re2", "utf8proc", 
    "bzip2", "brotli", "lz4", "zstd", "zlib",
    "gflags", -- gflags is used when enabling plasma
}

add_dep_configs(deps)
