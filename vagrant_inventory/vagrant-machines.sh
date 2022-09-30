#!/usr/bin/env bash
#set -x
function debug
{
  true
#  echo "DEBUG: $@"
}
function get_value
{
  echo "$1" | cut -d, -f$2
}
mapfile -t lines < <(vagrant global-status --machine-readable --prune)
machine_count=0
machine_index=0
echo "{"
for line in "${lines[@]}"; do
# 1664485616,,metadata,machine-count,3                            
  if expr "$line" : ".*machine-count.*" >/dev/null; then
    machine_count=$(get_value "$line" 5)
    debug "machine_count=$machine_count"

    # now grab that many chunks of
    # 1664485616,,machine-id,e1aecaf                                                                                                       
    # 1664485616,,provider-name,libvirt                               
    # 1664485616,,machine-home,/home/craig/cfe/starter_pack                                                                                
    # 1664485616,,state,shutoff  
  fi
  if expr "$line" : ".*machine-id.*" >/dev/null; then
    printf '"machine-%s": {' $machine_index
    value=$(get_value "$line" 4)
    printf '  "machine-id": "%s",' $value
  fi
  if expr "$line" : ".*provider-name.*" >/dev/null; then
    value=$(get_value "$line" 4)
    printf '  "provider-name": "%s",' $value
  fi
  if expr "$line" : ".*machine-home.*" >/dev/null; then
    value=$(get_value "$line" 4)
    printf '  "machine-home": "%s",' $value
  fi
  if expr "$line" : ".*state.*" >/dev/null; then
    value=$(get_value "$line" 4)
    printf '  "state": "%s"' $value
    echo -n "}"
    machine_index=$((machine_index + 1))
    if [ "$machine_index" -ge "$machine_count" ]; then
      echo
      echo "}"
      exit 0
    else
      echo ","
    fi
  fi
  debug "line $line"
done
