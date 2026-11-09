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
- Ajustes de red para streaming (BBR) y límites del sistema para muchos procesos FFmpeg.
- Vigilante de canales (`cdx-health`), que registra en `/var/log/stream-codex-health.log` los canales cuyo último segmento supera los 20 segundos.
- Herramienta de diagnóstico `cdx-diagnose` (solo lectura; oculta URLs y claves).
- Protección para que las actualizaciones de paquetes no reinicien el servidor ni el servicio automáticamente.

### Al terminar

- El panel queda disponible en `https://TU_IP_PUBLICA/dashboard`.
- El instalador comprueba la configuración instalada (servicio, panel, Nginx, HTTPS, certificado, FFmpeg, red y tareas programadas) y muestra cada resultado como OK o AVISO.
- El instalador muestra un enlace privado de configuración inicial. No lo compartas.
- Estado del servicio: `systemctl status stream-codex`
- Registro del servicio: `journalctl -u stream-codex -n 50 --no-pager`
- Diagnóstico completo: `cdx-diagnose`

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
62a68e45b3d79d9fb9f538efec2933b7b8cbfd60e4fc7b2b962da8ea04f784f9
```

Si el valor no coincide, no instales el paquete.

## Solución de problemas

- **"ya existe una instalación o configuración Stream Codex"**: el servidor no está limpio. El instalador está pensado solo para servidores nuevos.
- **La instalación se detiene con un error**: los archivos se conservan para diagnóstico. Revisa el final del registro:

```bash
tail -n 40 $(ls -t /var/log/stream-panel-install-*.log | head -n 1)
```

Si el instalador termina con **AVISOS**, ejecuta `cdx-diagnose` y revisa qué verificación no se confirmó. El registro del lanzador queda en `/var/log/stream-codex-launcher-*.log`.

## Límites conocidos

- La continuidad de los canales depende de la fuente, la red, el hardware y el reproductor. Este paquete no declara una capacidad máxima comprobada ni garantiza ausencia de cortes.
- Reiniciar el servicio `stream-codex` detiene todos los canales a la vez.
