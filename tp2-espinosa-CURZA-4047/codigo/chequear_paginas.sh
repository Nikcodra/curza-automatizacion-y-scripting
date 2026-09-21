#!/usr/bin/env bash

# Alumno: Ulises Espinosa
# Legajo: CURZA-4047
# Consulta códigos HTTP y guarda un reporte sin colores en logs/.

LEGAJO="CURZA-4047"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
RAIZ_TP=$(cd -- "$SCRIPT_DIR/.." && pwd)
ARCHIVO_SITIOS="$RAIZ_TP/sitios_${LEGAJO}.txt"
LOG_DIR="$RAIZ_TP/logs"
LOG_FILE="$LOG_DIR/chequeo_${LEGAJO}.log"

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl no está instalado." >&2
    exit 1
fi

urls=()

if [[ "$#" -gt 0 ]]; then
    urls=("$@")
else
    if [[ ! -r "$ARCHIVO_SITIOS" ]]; then
        echo "Error: no se puede leer $ARCHIVO_SITIOS" >&2
        exit 1
    fi

    while IFS= read -r url || [[ -n "$url" ]]; do
        [[ -z "$url" || "$url" == \#* ]] && continue
        urls+=("$url")
    done < "$ARCHIVO_SITIOS"
fi

if [[ "${#urls[@]}" -eq 0 ]]; then
    echo "Error: no hay URLs para verificar." >&2
    exit 1
fi

mkdir -p -- "$LOG_DIR"
{
    echo "Chequeo HTTP - $LEGAJO"
    echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
} > "$LOG_FILE"

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    VERDE=$(tput setaf 2)
    AMARILLO=$(tput setaf 3)
    ROJO=$(tput setaf 1)
    RESET=$(tput sgr0)
else
    VERDE=""
    AMARILLO=""
    ROJO=""
    RESET=""
fi

for url in "${urls[@]}"; do
    codigo=$(curl -s -o /dev/null -w '%{http_code}' \
        --connect-timeout 10 --max-time 20 "$url")
    resultado_curl=$?

    if [[ "$resultado_curl" -ne 0 ]]; then
        codigo="000"
    fi

    case "$codigo" in
        200)
            color="$VERDE"
            estado="OK"
            ;;
        3??)
            color="$AMARILLO"
            estado="REDIRECCIÓN"
            ;;
        4??|5??)
            color="$ROJO"
            estado="ERROR HTTP"
            ;;
        *)
            color="$ROJO"
            estado="SIN RESPUESTA"
            ;;
    esac

    printf '%sURL: %s - Código: %s - %s%s\n' "$color" "$url" "$codigo" "$estado" "$RESET"
    printf 'URL: %s - Código: %s - %s\n' "$url" "$codigo" "$estado" >> "$LOG_FILE"
done

echo "Reporte guardado en: $LOG_FILE"
exit 0
