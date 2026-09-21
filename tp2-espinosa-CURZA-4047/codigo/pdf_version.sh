#!/usr/bin/env bash

# Alumno: Ulises Espinosa
# Legajo: CURZA-4047
# Busca archivos PDF desde el directorio actual e informa su versión.

INICIALES="ue"
cantidad=0

while IFS= read -r -d '' archivo; do
    nombre="${archivo##*/}"
    nombre_minusculas="${nombre,,}"

    if [[ "$nombre_minusculas" == *excluir* || "$nombre_minusculas" == *"$INICIALES"* ]]; then
        continue
    fi

    primera_linea=$(LC_ALL=C head -n 1 -- "$archivo" 2>/dev/null)

    if [[ "$primera_linea" =~ %PDF-([0-9]+\.[0-9]+) ]]; then
        version="${BASH_REMATCH[1]}"
    else
        version="desconocida"
    fi

    printf 'Archivo: [%s] - Versión PDF: [%s]\n' "$archivo" "$version"
    cantidad=$((cantidad + 1))
done < <(find . -type f -iname '*.pdf' -print0)

if [[ "$cantidad" -eq 0 ]]; then
    echo "No se encontraron archivos PDF que cumplan el filtro."
fi

exit 0
