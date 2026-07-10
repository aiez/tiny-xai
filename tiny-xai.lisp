; vim: set lispwords+=loop,aif :
;;;; Script entry for tiny-xai: load the system and its tests,
;;;; then run the command line. Under ASDF, load the "tiny-xai"
;;;; system instead; the eval-when below never fires there.

(load (merge-pathnames "src/tiny-xai.lisp" *load-truename*))
(load (merge-pathnames "t/tiny-xai.lisp" *load-truename*))

(in-package :tiny-xai)

(eval-when (:execute)
  (if (member "-h" (args) :test #'equal)
      (help)
      (cli *my*)))
