local default_shared = false
local default_pic = true

local function spec(conf, opt)
    conf.system = false -- Avoid use system provided package.
    conf.build = false -- Allow use package from build-artifacts, set to true to force build locally.
    if opt ~= nil and opt.override == true then
        conf.override = true
    end

    if conf.configs == nil then
        conf.configs = {}
    end
    if conf.configs.shared == nil then
        conf.configs.shared = default_shared
    end
    if conf.configs.pic == nil then
        conf.configs.pic = default_pic
    end

    return conf
end

function gflags_configs(opt)
    return spec({version = "v2.2.2", configs = {mt = true}}, opt)
end

function zlib_configs(opt)
    return spec({version = "v1.2.11"}, opt)
end

function bzip2_configs(opt)
    return spec({version = "1.0.8"}, opt)
end

function lz4_configs(opt)
    return spec({version = "v1.9.3"}, opt)
end

function boost_configs(opt)
    -- The configs enabled here are not required by arrow.
    -- This is just an example to show how to enable different boost modules.
    return spec({
        version = "1.78.0",
        configs = {
            filesystem = true, system = true, serialization = true, container = true,
        },
    }, opt)
end

function openssl_configs(opt)
    return spec({version = "1.1.1m"}, opt)
end

function zstd_configs(opt)
    return spec({version = "1.5.2"}, opt)
end

function libevent_configs(opt)
    return spec({version = "2.1.12", configs = {openssl = true}}, opt)
end

function brotli_configs(opt)
    return spec({version = "1.0.9"}, opt)
end

function re2_configs(opt)
    return spec({version = "2022.02.01"}, opt)
end

function utf8proc_configs(opt)
    return spec({version = "v2.7.0"}, opt)
end

function thrift_configs(opt)
    return spec({version = "v0.16.0", configs = {ssl = true, zlib = true, libevent = true}}, opt)
end

function rapidjson_configs(opt)
    -- Arrow requires rapidjson commit 1a803826f1197b5e30703afe4b9c0e7dd48074f5
    -- We can let xrepo use a specific git commit by forking xmake-repo.
    -- Submit new issue or send PR to xmake-repo if you need this.
    return spec({version = "v1.1.0-arrow"}, opt)
end

-- For using arrow as a static C++ library.
function arrow_configs(opt)
    return spec({
        version = "7.0.0",
        configs = {
            mimalloc = true, jemalloc = false,
            engine = true, dataset = true, plasma = true, re2 = true, utf8proc = true,
            -- Link to third party library with static lib.
            -- When creating python shared lib in the same way as pyarrow python
            -- package, we should keep this as false while set default_pic to true.
            shared_dep = false,
            -- File format.
            -- json is disable because arrow requires a pre-release of rapidjson.
            csv = true, json = false, parquet = true,
            -- compression library.
            brotli = true, bz2 = true, lz4 = true, zlib = true, zstd = true,
            -- See arrow_python_configs()
            --python = true, shared = true
        }
    }, opt)
end

-- For building arrow as a shared library and enable python support.
function arrow_python_configs(opt)
    local config = arrow_configs(opt)
    config.configs.python = true
    config.configs.shared = true

    return config
end
