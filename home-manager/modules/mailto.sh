#!/usr/bin/env bash
# mailto — open a mailto: URI in neomutt (recipient, subject, cc, bcc).
set -euo pipefail

urldecode() {
  local s="$1" out="" c hex i=0
  s="${s//+/ }"
  while (( i < ${#s} )); do
    c="${s:i:1}"
    if [[ "$c" == "%" ]]; then
      hex="${s:i+1:2}"
      if [[ "$hex" =~ ^[0-9A-Fa-f]{2}$ ]]; then
        out+="$(printf '%b' "\\x$hex")"
      else
        out+="$c"
      fi
      i=$((i+3))
    else
      out+="$c"
      i=$((i+1))
    fi
  done
  printf '%s' "$out"
}

url="${1:-}"
url="${url#mailto:}"
url="${url#MAILTO:}"

addr="${url%%\?*}"
query="${url#*\?}"
[[ "$query" == "$url" ]] && query=""

subject=""
cc=""
bcc=""
if [[ -n "$query" ]]; then
  IFS='&' read -ra pairs <<< "$query"
  for pair in "${pairs[@]}"; do
    key="${pair%%=*}"
    val="${pair#*=}"
    case "$key" in
      subject | Subject) subject="$(urldecode "$val")" ;;
      cc | Cc)           cc="$(urldecode "$val")" ;;
      bcc | Bcc)         bcc="$(urldecode "$val")" ;;
    esac
  done
fi

args=()
[[ -n "$subject" ]] && args+=(-s "$subject")
[[ -n "$cc" ]]      && args+=(-c "$cc")
[[ -n "$bcc" ]]     && args+=(-b "$bcc")

if [[ -z "$addr" ]]; then
  exec neomutt "${args[@]}"
else
  exec neomutt "${args[@]}" -- "$addr"
fi
