includes("common.lua")

-- For building arrow with python support.
local arrow_config = copy_config(get_configs("arrow"))
arrow_config.configs.python = true
arrow_config.configs.shared = true

add_pkg("arrow", arrow_config)
