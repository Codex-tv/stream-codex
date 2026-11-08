# Stream Codex

Instalador oficial de Stream Codex para servidores Ubuntu.

## Compatibilidad

- Ubuntu Server 22.04 LTS
- Arquitectura amd64 (x86_64)

No se ha validado la instalación en Ubuntu 20.04 ni en otras versiones o arquitecturas.

## Requisitos

- Un servidor **nuevo**, sin instalaciones previas de Stream Codex. Si detecta una instalación o configuración existente, el instalador se detiene sin hacer cambios.
- Acceso como `root` o con `sudo`.
- Conexión a internet.
- Dirección IPv4 pública del servidor.
- Puertos 80 y 443 accesibles desde internet (necesarios para el certificado HTTPS).

## Instalación

Ejecuta este comando como `root` o con `sudo`:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Codex-tv/stream-codex/main/install.sh)"
```

El instalador solicita la dirección IPv4 pública del servidor. Tenla preparada antes de comenzar. También puedes indicarla directamente:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Codex-tv/stream-codex/main/install.sh)" install TU_IP_PUBLICA
```

Mantén la sesión SSH abierta hasta ver el mensaje de instalación completada. El proceso puede tardar varios minutos.

El comando descarga `Stream_Codex.zip` desde este repositorio, verifica su integridad y ejecuta el instalador.

### Qué instala

- Bibliotecas y herramientas del sistema, y Nginx.
- FFmpeg.
- Stream Codex, ejecutado como servicio de systemd (`stream-codex`).
- Respaldo automático diario.
- HTTPS con certificado de Let's Encrypt para la IP del servidor y renovación automática.

### Al terminar

- El panel queda disponible en `https://TU_IP_PUBLICA/dashboard`.
- El instalador muestra un enlace privado de configuración inicial. No lo compartas.
- Estado del servicio: `systemctl status stream-codex`
- Registro del servicio: `journalctl -u stream-codex -n 50 --no-pager`

## Instalación manual

1. Descarga `Stream_Codex.zip` desde este repositorio.
2. Verifica el paquete (ver la sección siguiente).
3. Descomprime, verifica el instalador y ejecútalo:

```bash
unzip -q Stream_Codex.zip
sha256sum -c Stream-Codex.sha256
sudo bash ./Stream-Codex
```

## Verificación del paquete

En el directorio donde descargaste el ZIP:

```bash
unzip -t Stream_Codex.zip
sha256sum Stream_Codex.zip
```

La suma SHA-256 del paquete actual es:

```
cced1fc2a5c4ab3022fb6d937bc69de39080cf585d3e08ba2e0aa2818d7333ed
```

Si el valor no coincide, no instales el paquete.

## Solución de problemas

- **"ya existe una instalación o configuración Stream Codex"**: el servidor no está limpio. El instalador está pensado solo para servidores nuevos.
- **La instalación se detiene con un error**: los archivos se conservan para diagnóstico. Revisa el final del registro:

```bash
tail -n 40 $(ls -t /var/log/stream-panel-install-*.log | head -n 1)
```
