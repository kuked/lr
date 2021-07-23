require_relative 'lib/lr/version'

Gem::Specification.new do |spec|
  spec.name          = "lr"
  spec.version       = Lr::VERSION
  spec.authors       = ["kuked"]
  spec.email         = ["kedoku@gmail.com"]

  spec.summary       = 'Yet Another an implementation of the Lox programming language.'
  spec.description   = 'Yet Another an implementation of the Lox programming language.'
  spec.homepage      = 'https://github.com/kuked/lr'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
