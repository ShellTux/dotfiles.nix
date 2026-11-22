-- toggle opacity
function()
    local opacity_rule = hl.window_rule({
        match = { focus = true },   -- for focused window
        opacity = "0.85 0.85 1.0",  -- (active/inactive/fullscreen opacity)
    })
    opacity_rule:set_enabled(not opacity_rule:is_enabled())
end
