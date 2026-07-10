(defsystem "tiny-xai-test"
  :author "Tim Menzies <timm@ieee.org>"
  :license "MIT"
  :depends-on ("tiny-xai")
  :components ((:module "t"
                :serial t
                :components ((:file "tiny-xai"))))
  :perform (test-op (o c)
             (declare (ignore o c))
             (uiop:symbol-call '#:tiny-xai '#:eg--all)))
