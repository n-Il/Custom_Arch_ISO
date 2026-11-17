dbus-update-activation-environment --systemd DISPLAY
xset s off
xset -dpms
xset b 0 0 0
xset b off
#xinput set-button-map 12 1 1 3 4 5 6 7
ibus-daemon --xim -drm &
exec awesome --no-argb >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
