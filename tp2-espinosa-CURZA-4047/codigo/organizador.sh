#!/usr/bin/env bash

# Alumno: Ulises Espinosa
# Legajo: CURZA-4047
# Clasifica los archivos de un directorio según su extensión.

if [[ "$#" -ne 1 ]]; then
    echo "Uso: $0 <directorio>" >&2
    exit 1
fi

directorio="$1"

if [[ ! -d "$directorio" || ! -r "$directorio" || ! -w "$directorio" || ! -x "$directorio" ]]; then
    echo "Error: el directorio no existe o no es accesible: $directorio" >&2
    exit 1
fi

mkdir -p -- \
    "$directorio/imagenes" \
    "$directorio/documentos" \
    "$directorio/comprimidos" \
    "$directorio/otros"

destino_libre() {
    local carpeta="$1"
    local nombre="$2"
    local candidato="$carpeta/$nombre"
    local numero=1

    while [[ -e "$candidato" ]]; do
        candidato="$carpeta/${nombre}.${numero}"
        numero=$((numero + 1))
    done

    printf '%s\n' "$candidato"
}

cantidad=0

while IFS= read -r -d '' archivo; do
    nombre="${archivo##*/}"
    nombre_minusculas="${nombre,,}"

    if [[ "$nombre_minusculas" == *.old ]]; then
        nombre="${nombre%.*}.backup"
        renombrado=$(destino_libre "$directorio" "$nombre")
        mv -- "$archivo" "$renombrado"
        archivo="$renombrado"
        nombre="${archivo##*/}"
        nombre_minusculas="${nombre,,}"
        echo "Renombrado: $nombre"
    fi

    case "$nombre_minusculas" in
        *.jpg|*.png)
            categoria="imagenes"
            ;;
        *.pdf|*.txt|*.docx)
            categoria="documentos"
            ;;
        *.zip|*.tar.gz|*.rar)
            categoria="comprimidos"
            ;;
        *)
            categoria="otros"
            ;;
    esac

    destino=$(destino_libre "$directorio/$categoria" "$nombre")
    mv -- "$archivo" "$destino"
    echo "Movido: $nombre -> $categoria/"
    cantidad=$((cantidad + 1))
done < <(find "$directorio" -maxdepth 1 -type f -print0)

echo "Organización finalizada. Archivos procesados: $cantidad"
exit 0
