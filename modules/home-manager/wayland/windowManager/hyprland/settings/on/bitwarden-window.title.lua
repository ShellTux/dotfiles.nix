function(window)
  if window ~= nil and (
      window.title == "Extension: (Bitwarden Password Manager) - — Mozilla Firefox"
      or
      window.title == "Bitwarden"
  ) then
    hl.dispatch(hl.dsp.focus({ window = window }))
    hl.dispatch(hl.dsp.window.float({ action = "enable", window = window }))
    hl.dispatch(hl.dsp.window.resize(mon_px(0.2, 0.5, false, { relative = false, window = window })))
    hl.timer(function()
      hl.dispatch(hl.dsp.window.center({ window = window }))
    end, { timeout = 1000, type = "oneshot" })
  end
end
