inotifywait -e close_write,moved_to,create -mr data/ src/ src/ |
while read path action file; do
  echo "The file '$file' appeared in directory '$path' via '$action'"
  crystal src/odkrywajac_polske.cr
  echo "Done"
done
