# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "simplehtml"
  spec.version       = "0.1.0"
  spec.authors       = ["Arca Ege Cengiz"]
  spec.email         = ["arcaegecengiz@gmail.com"]

  spec.summary       = "Simple HTML theme"
  spec.homepage      = "https://github.com/ArcaEge/ArcaEge.github.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_layouts|_includes|_sass|LICENSE|README)!i) }

  spec.add_runtime_dependency "jekyll", "~> 3.10"
  spec.add_runtime_dependency "jekyll-feed"

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_runtime_dependency "kramdown-parser-gfm", "~> 1.1"
  spec.add_runtime_dependency "bigdecimal"
  spec.add_runtime_dependency "base64"
  spec.add_runtime_dependency "html-proofer"
end
