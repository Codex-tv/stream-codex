#!/usr/bin/env bash
# =============================================================================
#  CODEX STREAM - Lanzador oficial de instalacion
#  By Codex Digital  |  Ubuntu Server 22.04 LTS (amd64)
#
#  Uso:  bash -c "$(curl -fsSL URL_DE_ESTE_SCRIPT)" install [IPV4_PUBLICA]
# =============================================================================
set -Eeuo pipefail

LAUNCHER_VERSION="2.0"
ZIP_URL="${STREAM_CODEX_ZIP_URL:-https://raw.githubusercontent.com/Codex-tv/stream-codex/main/Stream_Codex.zip}"

# --- helpers begin
C_RESET=''; C_GREEN=''; C_CYAN=''; C_WHITE=''; C_YELLOW=''; C_RED=''
if [[ -t 1 && -n "${TERM:-}" && "${TERM:-dumb}" != dumb && -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m'; C_GREEN=$'\033[92;1m'; C_CYAN=$'\033[96;1m'
  C_WHITE=$'\033[97;1m'; C_YELLOW=$'\033[93;1m'; C_RED=$'\033[91;1m'
fi
BOX_INNER=62
box_rule() { printf '%b+%s+%b\n' "$C_GREEN" "$(printf '%*s' "$BOX_INNER" '' | tr ' ' '-')" "$C_RESET"; }
box_line() {
  local text="$1" color="${2:-$C_WHITE}" left right
  (( ${#text} <= BOX_INNER )) || text="${text:0:BOX_INNER}"
  left=$(( (BOX_INNER - ${#text}) / 2 )); right=$(( BOX_INNER - ${#text} - left ))
  printf '%b|%b%*s%s%*s%b|%b\n' "$C_GREEN" "$color" "$left" '' "$text" "$right" '' "$C_GREEN" "$C_RESET"
}
show_brand() {
  local subtitle="${1:-INSTALADOR OFICIAL}"
  printf '\n'
  box_rule
  box_line ''
  box_line 'C O D E X   S T R E A M' "$C_WHITE"
  box_line 'By Codex Digital' "$C_CYAN"
  box_line ''
  box_line "$subtitle" "$C_WHITE"
  box_line ''
  box_rule
  printf '\n'
}
tag()  { printf '%b[%s]%b %s\n' "$1" "$2" "$C_RESET" "$3"; }
ok()   { tag "$C_GREEN"  '  OK  ' "$1"; }
info() { tag "$C_CYAN"   ' INFO ' "$1"; }
warn() { tag "$C_YELLOW" 'AVISO ' "$1"; }
err()  { tag "$C_RED"    'ERROR ' "$1" >&2; }
step() { printf '\n%b==> %s%b\n' "$C_WHITE" "$1" "$C_RESET"; }
# --- helpers end

WORKDIR=''
OK=0
LOG=''
INSTALLER_STARTED=0

cleanup() {
  cd /
  if [[ "$OK" == 1 ]]; then
    [[ -z "$WORKDIR" ]] || rm -rf -- "$WORKDIR"
  else
    if [[ -n "$WORKDIR" && -d "$WORKDIR" ]]; then
      printf '\n'
      warn "Instalacion no completada. Archivos conservados para diagnostico en: $WORKDIR"
    fi
    [[ -z "$LOG" ]] || warn "Registro del lanzador: $LOG"
    [[ "$INSTALLER_STARTED" != 1 ]] || warn 'Registro de la instalacion: /var/log/stream-panel-install-*.log'
  fi
  return 0
}
trap cleanup EXIT
trap 'err "Error inesperado en la linea $LINENO del lanzador."' ERR

die() { err "$1"; [[ -z "${2:-}" ]] || info "$2"; exit 1; }

run_logged() {
  # run_logged "mensaje en curso" "mensaje al terminar" comando...
  local doing="$1" done_msg="$2"; shift 2
  info "$doing"
  if "$@" >>"$LOG" 2>&1; then
    ok "$done_msg"
  else
    err "No se pudo completar: $doing"
    tail -n 20 "$LOG" >&2 || true
    die "Detalle completo en: $LOG"
  fi
}

case "${1:-}" in
  -h|--help)
    show_brand "LANZADOR DE INSTALACION"
    cat <<USAGE
Uso:
  bash -c "\$(curl -fsSL URL_DE_ESTE_SCRIPT)" install [IPV4_PUBLICA]

Requisitos: Ubuntu Server 22.04 LTS (amd64), servidor nuevo, acceso root o sudo.
Si no indicas la IPv4 publica, el instalador la solicitara.
USAGE
    OK=1
    exit 0
    ;;
esac

show_brand "INSTALADOR OFICIAL CODEX"
printf '%bUbuntu Server 22.04 LTS  |  amd64  |  Lanzador v%s%b\n' "$C_WHITE" "$LAUNCHER_VERSION" "$C_RESET"

# ---------------------------------------------------------------------------
step '[1/4] Verificacion previa del servidor'
# ---------------------------------------------------------------------------
[[ $EUID -eq 0 ]] || die 'Se requieren privilegios de administrador.' 'Ejecuta de nuevo con root o con sudo.'
ok 'Permisos de administrador'

LOG="/var/log/stream-codex-launcher-$(date +%Y%m%d-%H%M%S).log"
( umask 077; : >"$LOG" )

[[ -r /etc/os-release ]] || die 'No se pudo identificar el sistema operativo.'
. /etc/os-release
[[ "${ID:-}" == ubuntu && "${VERSION_ID:-}" == 22.04 ]] \
  || die "Sistema no compatible (${PRETTY_NAME:-desconocido}). Se requiere Ubuntu Server 22.04 LTS."
ok "Sistema compatible: ${PRETTY_NAME:-Ubuntu 22.04}"

[[ "$(dpkg --print-architecture)" == amd64 ]] || die 'Arquitectura no compatible. Se requiere amd64.'
ok 'Arquitectura amd64'

if [[ -d /opt/stream-codex || -e /var/lib/stream-codex/panel.db || -e /etc/nginx/sites-available/stream-codex ]]; then
  die 'Ya existe una instalacion de Stream Codex en este servidor.' \
      'No se hicieron cambios. Este instalador es solo para un servidor nuevo.'
fi
ok 'Servidor nuevo (sin instalacion previa)'

CPU_COUNT="$(nproc)"
RAM_MB="$(awk '/^MemTotal:/ {printf "%d", $2/1024}' /proc/meminfo)"
DISK_GB="$(df -BG --output=avail / | tail -n 1 | tr -dc '0-9')"
ok "Recursos: ${CPU_COUNT} vCPU, ${RAM_MB} MB de RAM, ${DISK_GB:-0} GB libres"
(( CPU_COUNT >= 2 ))        || warn 'Se recomiendan 2 vCPU o mas para varios canales simultaneos.'
(( RAM_MB >= 2000 ))        || warn 'Se recomiendan 2 GB de RAM o mas.'
(( ${DISK_GB:-0} >= 10 ))   || warn 'Se recomiendan 10 GB libres o mas (la preparacion del motor multimedia usa espacio temporal).'

if [[ -n "${1:-}" ]]; then
  [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || die "La direccion indicada no es una IPv4 valida: $1"
  ok "IPv4 publica indicada: $1"
fi

# ---------------------------------------------------------------------------
step '[2/4] Preparando el entorno del instalador'
# ---------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a NEEDRESTART_SUSPEND=1
run_logged 'Actualizando indices de paquetes de Ubuntu...' 'Indices de paquetes actualizados' \
  apt-get -o Acquire::Retries=3 update -qq
run_logged 'Instalando requisitos del lanzador (curl, unzip, certificados)...' 'Requisitos del lanzador instalados' \
  apt-get -o Acquire::Retries=3 install -y -qq ca-certificates curl unzip

WORKDIR="$(mktemp -d /tmp/stream-codex.XXXXXX)"
cd "$WORKDIR"

# ---------------------------------------------------------------------------
step '[3/4] Descargando y verificando Stream Codex'
# ---------------------------------------------------------------------------
run_logged 'Descargando el paquete oficial...' 'Paquete descargado' \
  curl --fail --show-error --silent --location --retry 3 --retry-delay 2 --connect-timeout 20 \
       --proto '=https' --tlsv1.2 "$ZIP_URL" -o Stream_Codex.zip
info "Tamano del paquete: $(du -h Stream_Codex.zip | cut -f1)"
run_logged 'Comprobando que el paquete no este danado...' 'Paquete valido' unzip -tq Stream_Codex.zip
run_logged 'Extrayendo el paquete...' 'Paquete extraido' unzip -oq Stream_Codex.zip
[[ -f Stream-Codex && -f Stream-Codex.sha256 ]] || die 'El paquete esta incompleto (faltan archivos del instalador).'
run_logged 'Verificando la integridad (SHA-256)...' 'Integridad verificada (SHA-256)' sha256sum -c Stream-Codex.sha256

# ---------------------------------------------------------------------------
step '[4/4] Ejecutando el instalador de Stream Codex'
# ---------------------------------------------------------------------------
export STREAM_CODEX_BRANDED=1
INSTALLER_STARTED=1
if ! bash ./Stream-Codex "$@"; then
  err 'El instalador de Stream Codex no se completo.'
  exit 1
fi
OK=1
ok 'Lanzador finalizado. Archivos temporales eliminados.'
