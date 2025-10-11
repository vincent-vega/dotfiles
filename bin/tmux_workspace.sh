#!/bin/bash

tmux new-session -d -s w

tmux rename-window -t w:0 ''
# not necessary but keeping for future reference
tmux send-keys ' cd ~/Downloads; tmux wait-for -S move' Enter\; wait-for move
tmux send-keys ' ranger' Enter

tmux new-window -n 'mnt'
tmux send-keys ' htop' Enter
tmux split-window -v
tmux send-keys ' btop' Enter
tmux split-window -v
tmux send-keys ' while true; do ping www.reddit.com; sleep 2; done' Enter

tmux select-layout even-vertical
tmux select-pane -t w:1.1
tmux resize-pane -D 7
tmux select-pane -t w:1.2

tmux select-window -t w:0

tmux attach-session -t w
