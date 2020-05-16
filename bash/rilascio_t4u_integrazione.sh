#!/usr/bin/env bash

SESSION_NAME=deploy

tmux -2 new-session -d -s $SESSION_NAME \; split-window -h

tmux select-pane -t 1
tmux send-keys "ssh8" C-m
tmux send-keys "cd /home/deploy" C-m
tmux send-keys "ll" C-m
tmux split-window -v
tmux select-pane -t 2
tmux send-keys "ssh9" C-m
tmux send-keys "cd /home/deploy" C-m
tmux send-keys "ll" C-m

tmux select-pane -t 0
tmux send-keys "cd ~/Desktop/Time4UserServices/" C-m
tmux send-keys "svn update; tmux wait-for -S svn-update" C-m\; wait-for svn-update
tmux send-keys "mvn clean package" C-m

tmux -2 attach-session -t $SESSION_NAME


