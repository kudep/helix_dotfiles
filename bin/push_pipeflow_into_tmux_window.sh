#! /bin/bash

check_is_in_tmux()
{
  if [ -z "$TMUX" ]
  then
    echo error: run outside of tmux
    exit 1
  fi
}

help()
{
    echo "$(basename "$0") [-h] [-w window_name_string] -- this program push piped input into a specific window of tmux

example (run tmux with two windows, one window with name 'python' and in another window execute this example):
    echo print('Hello') | ./bin/push_pipeflow_into_tmux_window.sh -w python

where:
    -h  show this help text
    -w  set the window name (default: python)"
}

handle_args()
{
  WINDOW_NAME=python
  while getopts ":hw:" option; do
    case "${option}" in
    h)
        help
        exit;;
    w)
        WINDOW_NAME=$OPTARG
        # return ;;
        shift; shift;;
    \?) # incorrect option
         echo "error: invalid option"
         help
         exit;;
    esac
  done
}

init_additional_args()
{
  SESSION_ID=$(echo "$TMUX" | sed "s/.*,.*,//g")
  TARGET_PANE=$(tmux lsp -aF '#{window_name}#{session_id}<>#{session_name}:#{window_id}.#{pane_id}' | grep $WINDOW_NAME | grep '$'$SESSION_ID'<>' | head -n 1 | sed "s/.*<>//g")
  TMP_BUF_FILE="/tmp/"$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 8)".buf"
  # echo SESSION_ID=$SESSION_ID
  # echo TARGET_PANE=$TARGET_PANE
  # echo TMP_BUF_FILE=$TMP_BUF_FILE
}

push_into_specific_window()
{
  cat > $TMP_BUF_FILE
  tmux load-buffer -b tmp-buf $TMP_BUF_FILE
  tmux paste-buffer -b tmp-buf -d -t $TARGET_PANE
  rm $TMP_BUF_FILE
}

check_is_in_tmux
handle_args $@
# echo WINDOW_NAME=$WINDOW_NAME
init_additional_args
push_into_specific_window