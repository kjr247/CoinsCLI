jgl() {

  local start=$(date +%s)   # Capture start time
  local sparkle_flag="/tmp/notifyme_sparkle_$$"
  # Clean up any old flag file from previous runs
  rm -f "$sparkle_flag"
  local notifyme_marker="notifyme-$$"
  touch "$sparkle_flag"

  # Subtle sparkle/heartbeat sound every 5 seconds while running

  (
    while :; do
      if [ ! -f "$sparkle_flag" ]; then
        break
      fi
      powershell.exe -NoProfile -Command "[console]::beep(200,20); Start-Sleep -Milliseconds 60; [console]::beep(100,20) # $notifyme_marker" &>/dev/null &
      local bash_pid=$!
      wait $bash_pid
      sleep 15
    done
    # Extra cleanup: remove flag file if still present (background process exit)
    rm -f "$sparkle_flag"
  ) >/dev/null 2>&1 &
  local sparkle_pid=$!
  disown $sparkle_pid

  # Trap to clean up on exit or interruption (set in main shell, not subshell)
  cleanup_notifyme() {
    rm -f "$sparkle_flag"
    if [ -n "$sparkle_pid" ] && kill -0 "$sparkle_pid" 2>/dev/null; then
      kill "$sparkle_pid" 2>/dev/null
      wait "$sparkle_pid" 2>/dev/null
    fi
    trap - EXIT INT TERM
  }
  trap cleanup_notifyme INT TERM


  "$@"
  local status=$?
  local end=$(date +%s)
  local duration=$((end - start))

  # Always clean up at the end
  cleanup_notifyme

  if [ "$status" -eq 0 ]; then
    if [ $duration -ge 60 ]; then
      # Grand success melody (long-running command)
      powershell.exe -NoProfile -Command "
        [console]::beep(1047,80); Start-Sleep -Milliseconds 5;
        [console]::beep(1318,80); Start-Sleep -Milliseconds 5;
        [console]::beep(1568,100); Start-Sleep -Milliseconds 5;
        [console]::beep(1760,100); Start-Sleep -Milliseconds 5;
        [console]::beep(1976,150); Start-Sleep -Milliseconds 5;
        [console]::beep(1568,150);
      "
    elif [ $duration -ge 30 ]; then
      # Long success: stacked melody
      powershell.exe -NoProfile -Command "
        [console]::beep(1047,100); Start-Sleep -Milliseconds 10;
        [console]::beep(1318,100); Start-Sleep -Milliseconds 10;
        [console]::beep(1568,150); Start-Sleep -Milliseconds 10;
        [console]::beep(1760,150);
      "
    else
      # Normal success chime (Mario-style)
      powershell.exe -NoProfile -Command "
        if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) {
          [console]::beep(1047,80); Start-Sleep -Milliseconds 30;
          [console]::beep(1318,80); Start-Sleep -Milliseconds 30;
          [console]::beep(1568,150);
        } else {
          [console]::beep(1047,60); Start-Sleep -Milliseconds 20;
          [console]::beep(1568,150);
        }
      "
    fi
  else
    # Failure: randomly choose between two “oops” tones
    powershell.exe -NoProfile -Command "
      if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) {
        [console]::beep(523,100); Start-Sleep -Milliseconds 40;
        [console]::beep(440,150); Start-Sleep -Milliseconds 30;
        [console]::beep(360,200);
      } else {
        [console]::beep(400,150); Start-Sleep -Milliseconds 50;
        [console]::beep(330,200);
      }
    "
  fi
}