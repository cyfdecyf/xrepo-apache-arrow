includes("common.lua")

-- For building arrow with python support.
local arrow_config = copy_config(get_configs("arrow"))
arrow_config.configs.python = true
arrow_config.configs.shared = true

add_requires("arrow", arrow_config)

local deps = {
    "thrift", "boost", "libevent", "openssl",
    "rapidjson", "re2", "utf8proc", 
    "bzip2", "brotli", "lz4", "zstd", "zlib",
    "gflags", -- gflags is used when enabling plasma
}

add_dep_configs(deps)
