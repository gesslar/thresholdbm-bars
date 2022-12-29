-- /lua script.reset()
-- /lua script.load("/home/gesslar/git/thresholdbm-bars/main.lua")

ThresholdBM = {}
ThresholdBM.Vitals = ThresholdBM.Vitals or {}
ThresholdBM.Status = ThresholdBM.Status or {}
ThresholdBM.Colors = ThresholdBM.Colors or {
    bracket = C_WHITE,
    hp_fg = "\x1b[38;5;10m",
    hp_bg = "\x1b[38;5;2m",
    sp_fg = "\x1b[38;5;14m",
    sp_bg = "\x1b[38;5;6m",
    ep_fg = "\x1b[38;5;11m",
    ep_bg = "\x1b[38;5;3m",
}
ThresholdBM.Dots = ThresholdBM.Dots or {
    "░", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█", "▉", "█",
}

function ThresholdBM.DrawVitals()
    local hp    = ThresholdBM.Vitals["hp"] ;
    local hpmax = ThresholdBM.Vitals["maxhp"] ;
    local sp    = ThresholdBM.Vitals["sp"] ;
    local spmax = ThresholdBM.Vitals["maxsp"] ;
    local ep    = ThresholdBM.Vitals["ep"] ;
    local epmax = ThresholdBM.Vitals["maxep"] ;
    local hpper = 0 ;
    local spper = 0 ;
    local epper = 0 ;

    if hp and sp and ep and hpmax and spmax and epmax then
        hpper = math.floor(hp / hpmax * 100) ;
        spper = math.floor(sp / spmax * 100) ;
        epper = math.floor(ep / epmax * 100) ;
    end

    blight.status_line(0,
        "HP: [ "..tostring(hp).."/"..tostring(hpmax).." ("..tostring(hpper).."%) ] " ..
        "SP: [ "..tostring(sp).."/"..tostring(spmax).." ("..tostring(spper).."%) ] " ..
        "EP: [ "..tostring(ep).."/"..tostring(epmax).." ("..tostring(epper).."%) ] " ..
    "")
end

function ThresholdBM.DrawBars(width, height)
    local hp    = ThresholdBM.Vitals["hp"] ;
    local hpmax = ThresholdBM.Vitals["maxhp"] ;
    local sp    = ThresholdBM.Vitals["sp"] ;
    local spmax = ThresholdBM.Vitals["maxsp"] ;
    local ep    = ThresholdBM.Vitals["ep"] ;
    local epmax = ThresholdBM.Vitals["maxep"] ;

    if hp and sp and ep and hpmax and spmax and epmax then
        if width == nil or height == nil then
            width, height = blight.terminal_dimensions()
        end
        width = width - 7
        local bar_width = (math.floor(width / 3)) - 2
        local remainder = width % 3
        local hp_total_width = bar_width
        local sp_total_width = bar_width
        local ep_total_width = bar_width

        if remainder then
            sp_total_width = sp_total_width + 1
            remainder = remainder - 1
        end
        if remainder then
            ep_total_width = ep_total_width + 1
        end

        local hpper = math.floor(hp / hpmax * 100) ;
        local spper = math.floor(sp / spmax * 100) ;
        local epper = math.floor(ep / epmax * 100) ;

        local hp_width = math.floor(hpper * hp_total_width / 100)
        local sp_width = math.floor(spper * sp_total_width / 100)
        local ep_width = math.floor(epper * ep_total_width / 100)

        local hp_remainder = hp_total_width - hp_width
        local sp_remainder = sp_total_width - sp_width
        local ep_remainder = ep_total_width - ep_width

        local hpbar, spbar, epbar

        blight.status_line(1,
            ThresholdBM.Colors.bracket .. "[" ..
            ThresholdBM.Colors.hp_fg .. string.rep(ThresholdBM.Dots[11], hp_width) .. C_RESET ..
            ThresholdBM.Colors.hp_bg .. string.rep(ThresholdBM.Dots[1],  hp_remainder) .. C_RESET ..
            ThresholdBM.Colors.bracket .. "] ["..
            ThresholdBM.Colors.sp_fg .. string.rep(ThresholdBM.Dots[11], sp_width) .. C_RESET ..
            ThresholdBM.Colors.sp_bg .. string.rep(ThresholdBM.Dots[1],  sp_remainder) .. C_RESET ..
            ThresholdBM.Colors.bracket .. "] ["..
            ThresholdBM.Colors.ep_fg .. string.rep(ThresholdBM.Dots[11], ep_width) .. C_RESET ..
            ThresholdBM.Colors.ep_bg .. string.rep(ThresholdBM.Dots[1],  ep_remainder) .. C_RESET ..
            ThresholdBM.Colors.bracket .. "]" ..
        "")
    end
end

function ThresholdBM.CharVitals(data)
    local obj = json.decode(data)
    for k, v in pairs(obj) do
        if k ~= "string" then
            ThresholdBM.Vitals[k] = tonumber(v)
        end
    end
    ThresholdBM.DrawVitals()
    ThresholdBM.DrawBars()
end

-- function ThresholdBM.CharStatus(data)
--     ThresholdBM.UpdateFoe(data)
--     ThresholdBM.
-- end

gmcp.on_ready(function ()
    ThresholdBM.DrawVitals()
    blight.output("Registering GMCP")
    blight.status_height(2)
    gmcp.register("Char")
    gmcp.receive("Char.Vitals", function(data) ThresholdBM.CharVitals(data) end)
    blight.on_dimensions_change(function(width, height) ThresholdBM.DrawBars(width, height) end)
end)
