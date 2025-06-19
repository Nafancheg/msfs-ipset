local fs = require "nixio.fs"

local m = Map("msfs_domains", "Microsoft Flight Simulator Domains")

-- TypedSection с одной фиктивной секцией "cfg"
local s = m:section(TypedSection, "config", "Список доменов")
s.anonymous = true
s.addremove = false

function s:cfgsections()
    return {"cfg"}
end

local domains = s:option(TextValue, "domains")
domains.rows = 15
domains.wrap = "off"

function domains.cfgvalue(self, section)
    if section ~= "cfg" then
        return ""
    end
    if fs.access("/etc/msfs_domains.list") then
        local f = io.open("/etc/msfs_domains.list", "r")
        if f then
            local content = f:read("*all")
            f:close()
            return content
        end
    end
    return ""
end

function domains.write(self, section, value)
    if section ~= "cfg" then
        return
    end
    value = value:gsub("\r", "")
    local f = io.open("/etc/msfs_domains.list", "w")
    if f then
        f:write(value)
        f:close()
    end
end

return m

