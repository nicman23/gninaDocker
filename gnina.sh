#!/usr/bin/env bash

python gnina-api.py


gnina-virtualscreen() {
    local infile="$1"
    local filepfx="$(basename ${infile%.sdf*})"
    local outfile="results/${filepfx}.sdf"
    local logfile="logs/${filepfx}.log"
    local mytime0
    local mytime1
    
    [ -f "$outfile" ] && return 0

    mytime0=$(date +%s)
    echo "Docking started at: $(date +'%Y-%m-%d %H:%M:%S' -d @$mytime0)"
    echo "... Receptor: '$GNINA_RECFILE'"
    echo "... Input:    '$infile'"
    echo "... Output:   '$outfile'"
    gnina \
        -r "$GNINA_RECFILE" -l "$infile" \
        --autobox_ligand "$GNINA_AUTOBOX" \
        -o "$outfile" \
        --num_modes 1 --addH no --seed 42 \
        --cpu 8 > "$logfile"

    mytime1=$(date +%s)
    echo "Docking finished at: $(date +'%Y-%m-%d %H:%M:%S' -d @$mytime1)"
    echo "Time elapsed: $((mytime1 - mytime0)) seconds."
}

#
# ::: MAIN
#
export GNINA_RECFILE="$(find /data/ligands -name '*.sdf')"
export GNINA_AUTOBOX="$(find /data/box -name '*.sdf')"
export -f gnina-virtualscreen
export CUDA_VISIBLE_DEVICES=1
mkdir -p results logs

INPUT_SDFILES=( $(find /data/ligands -name '*.sdf') )

# Redirect STDERR -> STDOUT
LOGFILE=gnina_logfile${CUDA_VISIBLE_DEVICES}.log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec > "$LOGFILE" 2>&1

parallel -j5 gnina-virtualscreen {} ::: ${INPUT_SDFILES[@]}
