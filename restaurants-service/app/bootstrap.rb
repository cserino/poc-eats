load "vendor/bundle/bundler/setup.rb"
$LOAD_PATH.unshift(File.expand_path(".", __dir__))

require 'platform'
Platform.init_database!

def Kernel.method_missing(name, *args, **kwargs)
  puts "method_missing? #{name} #{name.class.to_s}"

  name_str = name.to_s
  super unless name_str.include? '#'

  clazz, method = name_str.split('#')
  c = const_get(clazz)
  handler = c.new

  # before_method = "before_#{method}"
  response = handler.send(:before_action, *args, **kwargs) if handler.respond_to? :before_action
  puts "is a? #{response.class}"
  return response if response.is_a?(Hash) && response.key?(:statusCode)
  handler.send(method, *args, **kwargs)
end
