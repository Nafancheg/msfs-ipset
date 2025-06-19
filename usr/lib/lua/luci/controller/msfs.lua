module("luci.controller.msfs", package.seeall)

function index()
    entry({"admin", "services", "msfs_domains"}, cbi("msfs"), _("MSFS Domains"), 60).dependent = false
end
