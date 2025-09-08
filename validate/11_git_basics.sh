#!/usr/bin/env bash
set -e
[ -d "$HOME/gitlab/.git" ] || { echo "FAIL: No git repo found"; exit 1; }
[ -f "$HOME/gitlab/file.txt" ] || { echo "FAIL: file.txt missing"; exit 1; }
git -C "$HOME/gitlab" log --oneline | grep -q "first commit" || { echo "FAIL: Commit not found"; exit 1; }
echo "PASS: Git Basics Completed"
