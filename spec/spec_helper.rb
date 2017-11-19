require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
require 'rspec-puppet-yaml'
require 'coveralls'
include RspecPuppetFacts

Coveralls.wear!

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

# Disable this BROKEN RuboCop offense because the author of it literally read
# the style guide backward and deployed an invalid test.  The style guide reads,
# "Avoid comma after the last parameter in a method call", NOT "Put a comma
# after the last parameter of a multiline method call"!
# rubocop:disable Style/TrailingCommaInArguments
default_facts_path =
  File.expand_path(
    File.join(File.dirname(__FILE__), 'default_facts.yml')
  )

default_module_facts_path =
  File.expand_path(
    File.join(File.dirname(__FILE__), 'default_module_facts.yml')
  )

if File.exist?(default_facts_path) && File.readable?(default_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_facts_path)))
end

# Disable this silly RuboCop offense because the style rule it cites does not
# cover "multi-line ifs" when there are multiple operands, requiring multi-line
# style to avoid stepping over Metrics/LineLength.  In this case, it is correct
# to use "then" in order to separate the complex if conditions from the block.
# rubocop:disable Style/MultilineIfThen
if File.exist?(default_module_facts_path) &&
   File.readable?(default_module_facts_path)
then
  default_facts.merge!(YAML.safe_load(File.read(default_module_facts_path)))
end

RSpec.configure do |c|
  c.default_facts = default_facts

  # Coverage generation
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
