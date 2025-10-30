# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-ggn"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "General Gameplay Notation (GGN) - movement possibilities for board games"
  spec.description            = "A pure functional Ruby implementation of the General Gameplay Notation (GGN) specification v1.0.0. Provides a movement possibility oracle for evaluating pseudo-legal moves in abstract strategy board games. Features include hierarchical move navigation (piece → source → destination → transitions), pre-condition evaluation (must/deny). Works with Chess, Shogi, Xiangqi, and custom variants."
  spec.homepage               = "https://github.com/sashite/ggn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*.rb"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "sashite-cell", "~> 2.0"
  spec.add_dependency "sashite-hand", "~> 1.0"
  spec.add_dependency "sashite-lcn", "~> 0.1"
  spec.add_dependency "sashite-qpi", "~> 1.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/ggn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/ggn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/ggn.rb",
    "source_code_uri"       => "https://github.com/sashite/ggn.rb",
    "specification_uri"     => "https://sashite.dev/specs/ggn/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
