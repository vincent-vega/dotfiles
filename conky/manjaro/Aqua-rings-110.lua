--============================================================================
-- Aqua-rings-110.lua, based on sun_rings

-- I just tweaked the cpu rings, and disc paths ;)

-- by damo, July 2017 <damo@bunsenlabs.org>
--============================================================================
--                            sun_rings.lua

--  Date    : 05 July 2017
--  Author  : Sun For Miles
--  Version : v0.41
--  License : Distributed under the terms of GNU GPL version 2 or later

--  This version is a modification of seamod_rings.lua which is modification of
--  lunatico_rings.lua which is modification of conky_orange.lua

--  conky_orange.lua:    http://gnome-look.org/content/show.php?content=137503
--  lunatico_rings.lua:  http://gnome-look.org/content/show.php?content=142884
--  seamod_rings.lua:    http://custom-linux.deviantart.com/art/Conky-Seamod-v0-1-283461046
--============================================================================

require 'cairo'

------------------------------------------------------------------------------
--                                                                  gauge DATA
-- Rings are built from the detected hardware (see sysinfo.lua): one CPU ring
-- per logical CPU, one disk ring per mounted filesystem (rescanned at runtime),
-- network rings on the default-route interface.

local script_dir = debug.getinfo(1, 'S').source:match('^@(.*/)') or './'
local sysinfo = dofile(script_dir .. 'sysinfo.lua')

-- ring centres, matching the conkyrc text layout
local LINE_HEIGHT = 17          -- one text row (SFMono Nerd Font size 10)
local MIN_DISK_ROWS = 3         -- conky_disk_rows() pads to this many rows
local CPU_Y, MEM_Y, DISK_Y, NET_Y = 172, 377, 585, 745  -- NET_Y with MIN_DISK_ROWS rows

local ring_defaults = {
    max_value=100,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.1,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.3,
    hand_fg_colour=0x678b8b,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                  txt_size=9.0,
    txt_fg_colour=0x678b8b,        txt_fg_alpha=0,
    graduation_radius=0,
    graduation_thickness=0,        graduation_mark_thickness=1,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='',
    caption_weight=0.5,            caption_size=12.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
}

local function ring(fields)
    return setmetatable(fields, { __index = ring_defaults })
end

local net_iface = sysinfo.net_iface()
local cpu_count = sysinfo.cpu_count()
local mounts = {}
local mounts_key = ''
gauge = {}

local function build_gauges()
    gauge = {}

    -- CPU: concentric rings, outermost is cpu1
    local step = cpu_count > 1 and math.min(6, 24 / (cpu_count - 1)) or 0
    local thickness = cpu_count > 1 and math.max(1, math.min(5, step - 1)) or 5
    for i = 1, cpu_count do
        table.insert(gauge, ring{
            name='cpu', arg='cpu' .. i, x=100, y=CPU_Y,
            graph_radius=54 - (i - 1) * step, graph_thickness=thickness,
            graph_bg_alpha=0.2, graph_fg_alpha=0.8,
        })
    end

    table.insert(gauge, ring{
        name='memperc', arg='', x=100, y=MEM_Y,
        graph_radius=54, graph_thickness=15,
    })

    -- disks: root innermost, extra mounts outwards
    local n = #mounts
    step = n > 1 and math.min(12, 24 / (n - 1)) or 0
    for i, m in ipairs(mounts) do
        table.insert(gauge, ring{
            name='fs_used_perc', arg=m.path, x=100, y=DISK_Y,
            graph_radius=54 - (n - i) * step,
            graph_thickness=n > 1 and math.min(7, step - 2) or 7,
            caption=m.caption, caption_size=n > 1 and math.min(12, step) or 12,
        })
    end

    -- network: follows the disk rows, which may be more than MIN_DISK_ROWS
    local net_y = NET_Y + math.max(0, n - MIN_DISK_ROWS) * LINE_HEIGHT
    local full_scale = sysinfo.link_speed_kib(net_iface)
    for i, dir in ipairs({ 'down', 'up' }) do
        table.insert(gauge, ring{
            name=dir .. 'speedf', arg=net_iface, full_scale=full_scale, x=90, y=net_y,
            graph_radius=66 - i * 12, graph_thickness=7,
            hand_fg_alpha=0,
            caption=dir == 'down' and 'Down' or 'Up', caption_size=11.0,
        })
    end
end

-- rebuild when the set of mounted filesystems changes
local function refresh_mounts()
    local key = ''
    for _, m in ipairs(sysinfo.mounts()) do key = key .. m.path .. '\n' end
    if key ~= mounts_key then
        mounts_key = key
        mounts = sysinfo.mounts_with_captions()
        build_gauges()
    end
end

refresh_mounts()

-- ${lua_parse disk_rows}: one "Free / Used" row per ring, padded to MIN_DISK_ROWS
function conky_disk_rows()
    local rows = {}
    for _, m in ipairs(mounts) do
        table.insert(rows, string.format('${offset 117}Free: ${fs_free %s} ${alignr}Used: ${fs_used %s}', m.path, m.path))
    end
    for _ = #rows + 1, MIN_DISK_ROWS do table.insert(rows, '') end
    return table.concat(rows, '\n    ')
end

------------------------------------------------------------------------------
--                                                                rgb_to_r_g_b
-- converts color in hexa to decimal

function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

------------------------------------------------------------------------------
--                                                           angle_to_position
-- convert degree to rad and rotate (0 degree is top/north)

function angle_to_position(start_angle, current_angle)
    local pos = current_angle + start_angle
    return ( ( pos * (2 * math.pi / 360) ) - (math.pi / 2) )
end


------------------------------------------------------------------------------
--                                                             draw_gauge_ring
-- displays gauges

function draw_gauge_ring(display, data, value)
    local max_value = data['max_value']
    local x, y = data['x'], data['y']
    local graph_radius = data['graph_radius']
    local graph_thickness, graph_unit_thickness = data['graph_thickness'], data['graph_unit_thickness']
    local graph_start_angle = data['graph_start_angle']
    local graph_unit_angle = data['graph_unit_angle']
    local graph_bg_colour, graph_bg_alpha = data['graph_bg_colour'], data['graph_bg_alpha']
    local graph_fg_colour, graph_fg_alpha = data['graph_fg_colour'], data['graph_fg_alpha']
    local hand_fg_colour, hand_fg_alpha = data['hand_fg_colour'], data['hand_fg_alpha']
    local graph_end_angle = (max_value * graph_unit_angle) % 360

    -- background ring
    cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, 0), angle_to_position(graph_start_angle, graph_end_angle))
    cairo_set_source_rgba(display, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
    cairo_set_line_width(display, graph_thickness)
    cairo_stroke(display)

    -- arc of value (clamped; rescaled to max_value when the gauge sets full_scale)
    local full_scale = data['full_scale'] or max_value
    local val = math.min(math.max(value, 0), full_scale) * max_value / full_scale
    local start_arc = 0
    local stop_arc = 0
    local i = 1
    while i <= val do
        start_arc = (graph_unit_angle * i) - graph_unit_thickness
        stop_arc = (graph_unit_angle * i)
        cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
        cairo_set_source_rgba(display, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
        cairo_stroke(display)
        i = i + 1
    end
    local angle = start_arc

    -- hand
    start_arc = (graph_unit_angle * val) - (graph_unit_thickness * 2)
    stop_arc = (graph_unit_angle * val)
    cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
    cairo_set_source_rgba(display, rgb_to_r_g_b(hand_fg_colour, hand_fg_alpha))
    cairo_stroke(display)

    -- graduations marks
    local graduation_radius = data['graduation_radius']
    local graduation_thickness, graduation_mark_thickness = data['graduation_thickness'], data['graduation_mark_thickness']
    local graduation_unit_angle = data['graduation_unit_angle']
    local graduation_fg_colour, graduation_fg_alpha = data['graduation_fg_colour'], data['graduation_fg_alpha']
    if graduation_radius > 0 and graduation_thickness > 0 and graduation_unit_angle > 0 then
        local nb_graduation = graph_end_angle / graduation_unit_angle
        local i = 0
        while i < nb_graduation do
            cairo_set_line_width(display, graduation_thickness)
            start_arc = (graduation_unit_angle * i) - (graduation_mark_thickness / 2)
            stop_arc = (graduation_unit_angle * i) + (graduation_mark_thickness / 2)
            cairo_arc(display, x, y, graduation_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
            cairo_set_source_rgba(display,rgb_to_r_g_b(graduation_fg_colour,graduation_fg_alpha))
            cairo_stroke(display)
            cairo_set_line_width(display, graph_thickness)
            i = i + 1
        end
    end

    -- text
    local txt_radius = data['txt_radius']
    local txt_weight, txt_size = data['txt_weight'], data['txt_size']
    local txt_fg_colour, txt_fg_alpha = data['txt_fg_colour'], data['txt_fg_alpha']
    local movex = txt_radius * math.cos(angle_to_position(graph_start_angle, angle))
    local movey = txt_radius * math.sin(angle_to_position(graph_start_angle, angle))
    cairo_select_font_face(display, "SFMono Nerd Font Mono", CAIRO_FONT_SLANT_NORMAL, txt_weight)
    cairo_set_font_size(display, txt_size)
    cairo_set_source_rgba(display, rgb_to_r_g_b(txt_fg_colour, txt_fg_alpha))
    cairo_move_to(display, x + movex - (txt_size / 2), y + movey + 3)
    cairo_show_text(display, value)
    cairo_stroke(display)

    -- caption
    local caption = data['caption']
    local caption_weight, caption_size = data['caption_weight'], data['caption_size']
    local caption_fg_colour, caption_fg_alpha = data['caption_fg_colour'], data['caption_fg_alpha']
    local tox = graph_radius * (math.cos((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
    local toy = graph_radius * (math.sin((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
    cairo_select_font_face (display, "SFMono Nerd Font Mono", CAIRO_FONT_SLANT_NORMAL, caption_weight);
    cairo_set_font_size(display, caption_size)
    cairo_set_source_rgba(display, rgb_to_r_g_b(caption_fg_colour, caption_fg_alpha))
    cairo_move_to(display, x + tox + 1, y + toy + 5)
    -- bad hack but not enough time !
    if graph_start_angle < 105 then
        cairo_move_to(display, x + tox - 30, y + toy + 1)
    end
    cairo_show_text(display, caption)
    cairo_stroke(display)
end


------------------------------------------------------------------------------
--                                                              go_gauge_rings
-- loads data and displays gauges

function go_gauge_rings(display)
    local function load_gauge_rings(display, data)
        local str, value = '', 0
        str = string.format('${%s %s}',data['name'], data['arg'])
        str = conky_parse(str)
        value = tonumber(str) or 0
        draw_gauge_ring(display, data, value)
    end

    for _, data in ipairs(gauge) do
        load_gauge_rings(display, data)
    end
end

------------------------------------------------------------------------------
--                                                                        MAIN
function conky_main()
    -- surface is owned by conky and only valid for this draw cycle: don't destroy it
    local cs = conky_surface()
    if cs == nil then
        return
    end

    local display = cairo_create(cs)

    local updates = conky_parse('${updates}')
    update_num = tonumber(updates)

    if update_num % 10 == 0 then
        refresh_mounts()
    end

    if update_num > 5 then
        go_gauge_rings(display)
    end

    cairo_destroy(display)

end
