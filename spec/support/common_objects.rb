# coding: utf-8
require 'time'

RSpec::Core::ExampleGroup.instance_eval do
  let(:null_pointer)   { FFI::Pointer.new(0) }
  let(:a_pointer)      { FFI::Pointer.new(1) }
end
