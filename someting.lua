-- Minimal test
if httpRequest then
    local ok, res = pcall(function()
        return httpRequest({ Url = "http://httpbin.org/get", Method = "GET", headers = {} })
    end)
    print("[Minimap] GET test ok:", ok)
    if ok then
        for k,v in pairs(res) do print(("  %s = %s"):format(tostring(k), tostring(v))) end
    else
        warn("[Minimap] GET test failed:", res)
    end
else
    warn("[Minimap] No httpRequest function available; aborting HTTP tests.")
end
