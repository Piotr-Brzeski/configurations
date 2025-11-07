#!/bin/zsh

DB_FILE="/tmp/$UID-tmux-status.db"
CURRENT_PATH="$1"
COMMAND=$2

read_from_db() {
    local FIELD=$1
    local TIMEOUT=$2
    local QUERY="SELECT value FROM status WHERE path='$CURRENT_PATH' AND field='$FIELD'"
    if (( $TIMEOUT > 0 )) 2>/dev/null; then
        QUERY="$QUERY AND time > strftime('%s', 'now', '-$TIMEOUT seconds')"
    fi
    sqlite3 "$DB_FILE" "$QUERY;"
}

write_to_db() {
    local FIELD=$1
    local VALUE=$2
    sqlite3 "$DB_FILE" "INSERT INTO status (path, field, time, value) VALUES ('$CURRENT_PATH', '$FIELD', strftime('%s', 'now'), '$VALUE') ON CONFLICT(path, field) DO UPDATE SET time=strftime('%s', 'now'), value='$VALUE';"
}

create_host() {
    local HOST="${USER}@$(hostname)"
    write_to_db "host" "$HOST"
    echo $HOST
}

get_host() {
    echo ${$(read_from_db host):-$(create_host)}
}

git_branch() {
    local BRANCH=$(git -C "$CURRENT_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null)
    write_to_db "branch" "$BRANCH"
    echo $BRANCH
}

get_branch() {
    echo ${$(read_from_db branch 5):-$(git_branch)}
}

git_status() {
    local OUTPUT=""
    local STATUS=$(git -C "$CURRENT_PATH" status --porcelain 2>/dev/null)
    local A=$(echo "$STATUS" | grep "^A" | wc -l | xargs)
    if [ "$A" -gt 0 ]; then
        OUTPUT="$OUTPUT +$A"
    fi
    local M=$(echo "$STATUS" | grep "^ M" | wc -l | xargs)
    if [ "$M" -gt 0 ]; then
        OUTPUT="$OUTPUT ~$M"
    fi
    local R=$(echo "$STATUS" | grep "^ D" | wc -l | xargs)
    if [ "$R" -gt 0 ]; then
       OUTPUT="$OUTPUT -$R"
    fi
    local U=$(echo "$STATUS" | grep "^??" | wc -l | xargs)
    if [ "$U" -gt 0 ]; then
       OUTPUT="$OUTPUT ×$U"
    fi
    OUTPUT=$(echo $OUTPUT | xargs)
    write_to_db "status" "$OUTPUT"
    echo "$OUTPUT"
}

get_status() {
    echo ${$(read_from_db status 5):-$(git_status)}
}

push_ns() {
    local NS=$1
    local HOST="$(get_host)/$NS"
    write_to_db "host" "$HOST"
}

pop_ns() {
    local HOST="$(get_host)"
    HOST="${HOST%/*}"
    write_to_db "host" "$HOST"
}

# Initialize database
if [ ! -f "$DB_FILE" ]; then
    echo "Initialize database"
    sqlite3 "$DB_FILE" "CREATE TABLE IF NOT EXISTS status (
        path TEXT NOT NULL,
        field TEXT NOT NULL,
        time INTEGER NOT NULL,
        value TEXT,
        PRIMARY KEY (path, field)
    );"
fi

case "$COMMAND" in
    --host)
        echo $(get_host)
        exit 0
        ;;
    --git-branch)
        echo $(get_branch)
        exit 0
        ;;
    --git-status)
        echo $(get_status)
        exit 0
        ;;
    --push-ns)
        NS="$3"
        if [[ -z $NS ]]; then
            exit 1
        fi
        echo $(push_ns "$NS")
        exit 0
        ;;
    --pop-ns)
        pop_ns
        exit 0
        ;;
    *)
    exit 1
esac

exit 1
