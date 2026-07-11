(defsystem "tiny-xai"
  :author "Tim Menzies <timm@ieee.org>"
  :maintainer "Tim Menzies <timm@ieee.org>"
  :license "MIT"
  :homepage "https://github.com/aiez/tiny-xai"
  :version "0.1"
  :description
  "Landscape analysis for XAI and optimization CSVs."
  :long-description
  #.(uiop:read-file-string
     (uiop:subpathname *load-pathname* "README.md"))
  :components ((:module "src"
                :serial t
                :components ((:file "tiny-xai"))))
  :in-order-to ((test-op (test-op "tiny-xai-test"))))

(defsystem "tiny-xai/dtlz"
  :description "DTLZ1-7 live-model driver for tiny-xai."
  :depends-on ("tiny-xai")
  :components ((:module "src"
                :components ((:file "dtlz")))))
