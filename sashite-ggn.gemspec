# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-ggn"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "General Gameplay Notation (GGN) - movement possibilities for board games"
  spec.description            = "A Ruby implementation of the General Gameplay Notation (GGN) specification. GGN is a rule-agnostic, JSON-based format for describing pseudo-legal movement possibilities in abstract strategy board games. This library provides parsing, validation, and querying capabilities for GGN documents, supporting piece movements, captures, drops, and complex transformations. Features include movement oracles, pre-condition evaluation, and STN-based state transitions. Supports Chess, Shogi, Xiangqi, and custom variants with full hand/reserve management."
  spec.homepage               = "https://github.com/sashite/ggn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*.rb"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "sashite-cell", "~> 2.0"
  spec.add_dependency "sashite-hand", "~> 1.0"
  spec.add_dependency "sashite-qpi", "~> 1.0"
  spec.add_dependency "sashite-stn", "~> 1.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/ggn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/ggn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/ggn.rb",
    "source_code_uri"       => "https://github.com/sashite/ggn.rb",
    "specification_uri"     => "https://sashite.dev/specs/ggn/1.0.0/",
    "rubygems_mfa_required" => "true",
    "keywords"              => %w[
      board-game
      chess
      game
      gameplay
      json
      movement-possibilities
      notation
      pseudo-legal-move
      rule-agnostic
      serialization
      shogi
      strategy
      validation
      xiangqi
    ].sort.join(", ")
  }
end
