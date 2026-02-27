Gem::Specification.new do |s|
  s.name          = "printnode"
  s.version       = "1.2.0"
  s.date          = "2026-02-27"
  s.summary       = "PrintNode-Ruby"
  s.description   = "Ruby API Library for PrintNode remote printing service."
  s.authors       = ["PrintNode","Jake Torrance"]
  s.email         = ["support@printnode.com"]
  s.files         = Dir.glob('lib/**/*.rb')
  s.homepage      = "https://www.printnode.com"
  s.license       = "MIT"
  s.required_ruby_version = '>= 2.7'
  s.post_install_message  = "Happy Printing!"
  s.add_development_dependency 'json', '>=0'
  s.add_development_dependency 'test-unit', '>=0'
end
