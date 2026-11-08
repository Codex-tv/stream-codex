# Stream Codex

Instalador oficial de Stream Codex para servidores Ubuntu.

## Compatibilidad

- Ubuntu Server 22.04 LTS
- Arquitectura amd64 (x86_64)

No se ha validado la instalación en Ubuntu 20.04 ni en otras versiones o arquitecturas.

## Paquete

Descarga `Stream_Codex.zip` desde la sección **Releases** de este repositorio. El paquete contiene el instalador y los archivos incluidos para la instalación.

Antes de instalar, verifica la suma SHA-256 publicada junto al archivo.

## Instalación

Ejecuta el instalador como `root` o mediante `sudo`, siguiendo los pasos y las indicaciones que aparecen en pantalla.

El instalador solicita la dirección IPv4 pública del servidor. Tenla preparada antes de comenzar.

## Verificación del paquete

En el directorio donde descargaste el ZIP:

```bash
unzip -t Stream_Codex.zip
sha256sum Stream_Codex.zip
