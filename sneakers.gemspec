# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sneakers"
  spec.version       = "0.0.1"
  spec.authors       = ["Jonathon M. Abbott"]
  spec.email         = ["jonathona@everydayhero.com.au"]
  spec.summary       = "EDH Order Signing Gem"
  spec.description   = spec.summary

  spec.files         = %x(git ls-files -z 2>/dev/null).split("\x0")
  spec.bindir        = "script"
  spec.executables   = spec.files.grep(%r{^script/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "bencode"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ">= 3.0"
end
