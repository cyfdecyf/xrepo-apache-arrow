includes("common.lua")

add_requires("arrow", arrow_configs())
-- TODO use * to simplify dependency spec.
-- gflags is used when plasma is enabled.
add_requireconfs("arrow.gflags", gflags_configs({override = true}))

-- boost, thrift all uses zlib, bzip2
add_requireconfs("arrow.zlib", zlib_configs({override = true}))
add_requireconfs("arrow.*.zlib", zlib_configs({override = true}))
add_requireconfs("arrow.bzip2", bzip2_configs({override = true}))
add_requireconfs("arrow.*.bzip2", bzip2_configs({override = true}))

add_requireconfs("arrow.boost", boost_configs({override = true}))
add_requireconfs("arrow.rapidjson", rapidjson_configs({override = true}))
add_requireconfs("arrow.re2", re2_configs({override = true}))
add_requireconfs("arrow.utf8proc", utf8proc_configs({override = true}))
add_requireconfs("arrow.brotli", brotli_configs({override = true}))
add_requireconfs("arrow.lz4", lz4_configs({override = true}))
add_requireconfs("arrow.zstd", zstd_configs({override = true}))

add_requireconfs("arrow.thrift", thrift_configs({override = true}))
add_requireconfs("arrow.thrift.openssl", openssl_configs({override = true}))
add_requireconfs("arrow.thrift.libevent", libevent_configs({override = true}))
add_requireconfs("arrow.thrift.libevent.openssl", openssl_configs({override = true}))
add_requireconfs("arrow.thrift.boost", boost_configs({override = true}))
add_requireconfs("arrow.thrift.boost.zlib", zlib_configs({override = true}))
add_requireconfs("arrow.thrift.boost.bzip2", bzip2_configs({override = true}))
