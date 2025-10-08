notifyme() {
  local start=$(date +%s)   # Capture start time
  "$@"                       # Run the command
  local status=$?            # Capture exit code
  local end=$(date +%s)
  local duration=$((end - start))

  if [ $status -eq 0 ]; then
    if [ $duration -ge 60 ]; then
      # Grand success melody (long-running command)
      powershell.exe -NoProfile -Command "
        [console]::beep(1047,80); Start-Sleep -Milliseconds 30;
        [console]::beep(1318,80); Start-Sleep -Milliseconds 30;
        [console]::beep(1568,100); Start-Sleep -Milliseconds 30;
        [console]::beep(1760,100); Start-Sleep -Milliseconds 30;
        [console]::beep(1976,150); Start-Sleep -Milliseconds 30;
        [console]::beep(1568,150);
      "
    elif [ $duration -ge 30 ]; then
      # Long success: stacked melody
      powershell.exe -NoProfile -Command "
        [console]::beep(1047,100); Start-Sleep -Milliseconds 30;
        [console]::beep(1318,100); Start-Sleep -Milliseconds 30;
        [console]::beep(1568,150); Start-Sleep -Milliseconds 30;
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
        [console]::beep(440,150); Start-Sleep -Milliseconds 50;
        [console]::beep(360,200);
      } else {
        [console]::beep(400,150); Start-Sleep -Milliseconds 50;
        [console]::beep(330,200);
      }
    "
  fi
}