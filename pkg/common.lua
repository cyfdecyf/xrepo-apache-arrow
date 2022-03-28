local default_shared = false
local default_pic = true

local all_configs = {
    gflags = {version = "v2.2.2", configs = {mt = true}},
    zlib = {version = "v1.2.11"},
    bzip2 = {version = "1.0.8"},
    lz4 = {version = "v1.9.3"},
    zstd = {version = "1.5.2"},
    brotli = {version = "1.0.9"},
    snappy = {version = "1.1.9"},
    boost = {
        version = "1.78.0",
        -- The configs enabled here are not required by arrow.
        -- This is just an example to show how to enable different boost modules.
        configs = {filesystem = true, system = true, serialization = true, container = true},
    },
    openssl = {version = "1.1.1m"},
    libevent ={version = "2.1.12", configs = {openssl = true}},
    re2 = {version = "2022.02.01"},
    utf8proc = {version = "v2.7.0"},
    thrift = {version = "v0.16.0", configs = {ssl = true, zlib = true, libevent = true}},
    -- Arrow requires rapidjson commit 1a803826f1197b5e30703afe4b9c0e7dd48074f5
    -- We can let xrepo use a specific git commit by forking xmake-repo.
    -- Submit new issue or send PR to xmake-repo if you need this.
    rapidjson = {version = "v1.1.0-arrow"},
    -- For using arrow as a static C++ library.
    arrow = {
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
            brotli = true, bz2 = true, lz4 = true, snappy = true, zlib = true, zstd = true,
            -- Configs for enable python support. Used in arrow-python.lua.
            -- python = true, shared = true
        },
    },
}

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

function copy_config(conf)
    local t = {}
    t.version = conf.version
    if conf.configs then
        c = {}
        for k, v in pairs(conf.configs) do
            c[k] = v
        end
        t.configs = c
    end
    return spec(t)
end

function get_configs(name, opt)
    local conf = all_configs[name]
    if conf == nil then
        print("WARNING no config found for package:", name)
        return
    end
    return spec(conf, opt)
end

function add_dep_configs(deps)
    for _, name in ipairs(deps) do
        add_requireconfs("**." .. name, get_configs(name, {override = true}))
    end
end
