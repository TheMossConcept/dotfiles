# Update passwords in pass
pass git push

# Update dotfiles
cd ~/.homesick/repos/dotfiles
git add -A
git commit -m "Dotfiles updated on shutdown"
git push

shutdown
