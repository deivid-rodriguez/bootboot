# frozen_string_literal: true

module Bootboot
  class RubySource
    include Bundler::Plugin::API::Source

    # The spec name for Ruby changed from "ruby\0" to "Ruby\0" between Bundler
    # 1.17 and 2.0, so we want to use the Ruby spec name from Metadata so
    # Bootboot works across Bundler versions
    def ruby_spec_name
      @ruby_spec_name ||= begin
        metadata = Bundler::Source::Metadata.new
        ruby_spec = metadata.specs.find { |s| s.name[/[R|r]uby\0/] }
        # Default to Bundler > 2 in case the Bundler internals change
        ruby_spec ? ruby_spec.name : "Ruby\0"
      end
    end

    def specs
      Bundler::Index.build do |idx|
        system_version = Bundler::RubyVersion.system.gem_version
        ruby_spec = Gem::Specification.new(ruby_spec_name, system_version)
        ruby_spec.source = self
        idx << ruby_spec
      end
    end

    def to_s
      "Bootboot plugin Ruby source"
    end
  end
end
