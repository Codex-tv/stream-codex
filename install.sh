#!/usr/bin/env bash
# Stream Codex - lanzador de instalación (Ubuntu Server 22.04 LTS, amd64)
# Uso:  bash -c "$(curl -fsSL URL_DE_ESTE_SCRIPT)" install [IPV4_PUBLICA]
set -euo pipefail

ZIP_URL="${STREAM_CODEX_ZIP_URL:-https://raw.githubusercontent.com/Codex-tv/stream-codex/main/Stream_Codex.zip}"

[[ $EUID -eq 0 ]] || { echo 'Error: ejecuta con root o con sudo.' >&2; exit 1; }

. /etc/os-release
[[ "${ID:-}" == ubuntu && "${VERSION_ID:-}" == 22.04 ]] || { echo 'Error: requiere Ubuntu Server 22.04 LTS.' >&2; exit 1; }
[[ "$(dpkg --print-architecture)" == amd64 ]] || { echo 'Error: requiere arquitectura amd64.' >&2; exit 1; }

echo '==> Instalando requisitos del lanzador...'
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ca-certificates curl unzip >/dev/null

WORKDIR="$(mktemp -d /tmp/stream-codex.XXXXXX)"
OK=0
cleanup() {
  cd /
  if [[ "$OK" == 1 ]]; then
    rm -rf -- "$WORKDIR"
  else
    echo "Instalación no completada. Archivos conservados para diagnóstico en: $WORKDIR" >&2
    echo 'Registro: /var/log/stream-panel-install-*.log' >&2
  fi
}
trap cleanup EXIT
cd "$WORKDIR"

echo '==> Descargando Stream Codex...'
curl --fail --show-error --location --retry 3 --proto '=https' --tlsv1.2 "$ZIP_URL" -o Stream_Codex.zip
unzip -tq Stream_Codex.zip
unzip -q Stream_Codex.zip
echo '==> Verificando integridad...'
sha256sum -c Stream-Codex.sha256

echo '==> Ejecutando el instalador...'
bash ./Stream-Codex "$@"
OK=1
