--============================================================================
-- sysinfo.lua: hardware detection shared by the conkyrc and the rings script
--============================================================================

local M = {}

local function read_line(path)
    local f = io.open(path)
    if not f then return nil end
    local l = f:read('l')
    f:close()
    return l
end

-- hwmon directories whose 'name' matches, in hwmon order
local function hwmon_dirs(name)
    local dirs = {}
    for i = 0, 63 do
        local d = '/sys/class/hwmon/hwmon' .. i
        if read_line(d .. '/name') == name then table.insert(dirs, d) end
    end
    return dirs
end

------------------------------------------------------------------------------
-- interface of the default route, else the first non-loopback interface up
function M.net_iface()
    local f = io.open('/proc/net/route')
    if f then
        f:read('l') -- header
        for l in f:lines() do
            local iface, dest = l:match('^(%S+)%s+(%x+)')
            if dest == '00000000' then f:close() return iface end
        end
        f:close()
    end
    local p = io.popen('ls /sys/class/net')
    for iface in p:lines() do
        if iface ~= 'lo' and read_line('/sys/class/net/' .. iface .. '/operstate') == 'up' then
            p:close()
            return iface
        end
    end
    p:close()
    return 'lo'
end

-- link speed in KiB/s (conky's downspeedf/upspeedf unit); 1 Gbit/s when unknown
-- (e.g. wifi, which reports no speed)
function M.link_speed_kib(iface)
    local mbit = tonumber(read_line('/sys/class/net/' .. iface .. '/speed') or '')
    if not mbit or mbit <= 0 then mbit = 1000 end
    return math.floor(mbit * 1000000 / 8 / 1024)
end

------------------------------------------------------------------------------
-- number of logical CPUs (conky's cpu1..cpuN)
function M.cpu_count()
    local n = 0
    for l in io.lines('/proc/cpuinfo') do
        if l:match('^processor') then n = n + 1 end
    end
    return math.max(n, 1)
end

------------------------------------------------------------------------------
-- CPU temperature sensors as { {label=, expr=conky expression}, ... }
-- Intel: per-core coretemp readings; AMD: every labelled k10temp/zenpower one
function M.cpu_temps()
    local temps = {}
    for _, chip in ipairs({ 'coretemp', 'k10temp', 'zenpower' }) do
        local dir = hwmon_dirs(chip)[1]
        if dir then
            for n = 1, 128 do
                local label = read_line(dir .. '/temp' .. n .. '_label')
                if label and (chip ~= 'coretemp' or label:match('^Core')) then
                    table.insert(temps, { label = label, expr = '${hwmon ' .. chip .. ' temp ' .. n .. '}' })
                end
            end
            if #temps > 0 then return temps end
        end
    end
    return temps
end

------------------------------------------------------------------------------
-- conky expression for the GPU temperature, or nil when there is none
function M.gpu_temp()
    for _, chip in ipairs({ 'amdgpu', 'radeon', 'nouveau', 'xe', 'i915' }) do
        for _, dir in ipairs(hwmon_dirs(chip)) do
            if read_line(dir .. '/temp1_input') then
                return '${hwmon ' .. chip .. ' temp 1}'
            end
        end
    end
    if read_line('/proc/driver/nvidia/version') then return '${nvidia temp}' end
    return nil
end

------------------------------------------------------------------------------
-- mounted disk filesystems: root, /home, then removable/extra mounts
-- returns { {path=, caption=}, ... }
local function mount_caption(path, dev, labels)
    if path == '/' then return 'Root' end
    if path == '/home' then return 'Home' end
    local caption = labels[path]
    if not caption or caption == '' then
        caption = path:match('([^/]+)$')
        -- unlabelled volumes get auto-mounted by UUID: the device name reads better
        if caption:match('^%x+$') or caption:match('^%x+%-[%x-]+$') then
            caption = dev:match('([^/]+)$')
        end
    end
    return caption:sub(1, 10)
end

function M.mounts()
    local found, seen = {}, {}
    for l in io.lines('/proc/mounts') do
        local dev, path = l:match('^(%S+)%s+(%S+)')
        path = path:gsub('\\(%d%d%d)', function(o) return string.char(tonumber(o, 8)) end)
        if dev:match('^/dev/') and not seen[path]
            and (path == '/' or path == '/home' or path:match('^/run/media/')
                 or path:match('^/media/') or path:match('^/mnt/')) then
            seen[path] = true
            table.insert(found, { path = path, dev = dev })
        end
    end
    local function rank(m)
        return (m.path == '/' and 0) or (m.path == '/home' and 1) or 2
    end
    table.sort(found, function(a, b)
        if rank(a) ~= rank(b) then return rank(a) < rank(b) end
        return a.path < b.path
    end)
    return found
end

-- same as mounts(), with captions (filesystem label when set)
function M.mounts_with_captions()
    local found = M.mounts()
    local labels = {}
    local p = io.popen('lsblk -rno MOUNTPOINTS,LABEL 2>/dev/null')
    if p then
        for l in p:lines() do
            local mp, label = l:match('^(%S+) (%S+)$')
            if mp then
                local unescape = function(s) return (s:gsub('\\x(%x%x)', function(h) return string.char(tonumber(h, 16)) end)) end
                labels[unescape(mp)] = unescape(label)
            end
        end
        p:close()
    end
    for _, m in ipairs(found) do m.caption = mount_caption(m.path, m.dev, labels) end
    return found
end

return M
