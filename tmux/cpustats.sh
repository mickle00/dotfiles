#!/bin/bash
INTERVAL=2
NUM_LINES=10

if [ -e /usr/local/bin/tmux-mem-cpu-load ]; then
    exec `tmux-mem-cpu-load ${INTERVAL} ${NUM_LINES}`
else
    if [[ "$(uname)" = "Darwin" ]]; then
        TOP=`top -l 1 | head -n 4 | tail -n 1|awk '{printf "%3d%%\n", $3}'`
        W=`w | head -n1 | cut -d":" -f4`
        CPU=${TOP%\%*}
        ACTIVE_LINES=$(($CPU/$NUM_LINES))
        LINES=""
        for (( i = 0; i < $NUM_LINES; i++ )); do
            if [[ $i < $ACTIVE_LINES ]]; then
                LINES="$LINES|"
            else
                LINES="$LINES "
            fi
        done
        FREE=`vm_stat | grep free | awk '{ print $3 }' | sed 's/\\.//'`
        TOTAL=`vm_stat | grep " active" | awk '{ print $3 }' | sed 's/\\.//'`
        FREE_MEM=$(( $TOTAL-$FREE ))
        USED_MEM=$(( $FREE_MEM/100 ))
        TOTAL_MEM=$(( $TOTAL/100 ))
        echo "MEM: $USED_MEM/$TOTAL_MEM MB | CPU: ${TOP} [${LINES}] LOAD: ${W}"
    fi
fi
