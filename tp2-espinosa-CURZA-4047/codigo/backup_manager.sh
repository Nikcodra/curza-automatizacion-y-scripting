#!/usr/bin/env bash

# Alumno: Ulises Espinosa
# Legajo: CURZA-4047
# Genera un respaldo e impide ejecuciones simultáneas mediante un lockfile.

LEGAJO="CURZA-4047"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
RAIZ_TP=$(cd -- "$SCRIPT_DIR/.." && pwd)
LOCK_DIR="/var/lock/backup_${LEGAJO}.lock"
TEMP_DIR="/tmp/backup_${LEGAJO}"
LOG_DIR="$RAIZ_TP/logs"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "Error: ya existe una ejecución de backup_manager.sh." >&2
    exit 9
fi

trap 'rmdir "/var/lock/backup_CURZA-4047.lock"' EXIT

rm -rf -- "$TEMP_DIR"
mkdir -p -- "$TEMP_DIR" "$LOG_DIR"

if ! cd -- "$SCRIPT_DIR"; then
    echo "Error: no se pudo acceder al directorio de código." >&2
    exit 1
fi

cantidad=0

while IFS= read -r -d '' archivo; do
    if ! cp --parents -- "$archivo" "$TEMP_DIR"; then
        echo "Error: no se pudo copiar $archivo" >&2
        exit 1
    fi
    cantidad=$((cantidad + 1))
done < <(find . -mtime -1 -type f -print0)

fecha=$(date '+%Y%m%d_%H%M%S')
archivo_backup="$LOG_DIR/backup_${LEGAJO}_${fecha}.tar.gz"

if ! tar -czf "$archivo_backup" -C "$TEMP_DIR" .; then
    echo "Error: no se pudo crear el archivo de respaldo." >&2
    exit 1
fi

echo "Respaldo creado: $archivo_backup"
echo "Archivos copiados: $cantidad"
exit 0
