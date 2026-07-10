# lispdoc preprocessing for pycco:
#  - ";;; ## name"   -> markdown heading comment
#  - ";;;" art lines -> dropped (figlet banners)
#  - ";;;;" prose    -> plain comment
#  - one-line docstrings lift ABOVE their defun as comments
BEGIN { n = 0 }
/^;;; ## /  { print ""; print ";; " substr($0, 5); next }
/^;;;;/     { print ";; " substr($0, 6); next }
/^;;;/      { next }
/^\((defun|defmethod|defmacro) / {
  n = 1; buf[n] = $0; next }
n && /^ +".*"$/ {
  doc = $0
  gsub(/^ +"|"$/, "", doc)
  print ";; " doc
  for (i = 1; i <= n; i++) print buf[i]
  n = 0; next }
n {
  if (n > 4 || $0 !~ /^ /) {
    for (i = 1; i <= n; i++) print buf[i]
    n = 0; print; next }
  buf[++n] = $0; next }
{ print }
