# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-ggn"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "General Gameplay Notation (GGN) library for board-to-board game transformations"
  spec.description            = "A Ruby implementation of the General Gameplay Notation (GGN) specification. GGN is a rule-agnostic, JSON-based format for describing pseudo-legal board-to-board transformations in abstract strategy board games. This library provides parsing, validation, and evaluation capabilities for GGN documents, focusing exclusively on piece movements, captures, and transformations on the game board. Supports Chess, Shogi, Xiangqi, and custom variants without hand management or piece drops."
  spec.homepage               = "https://github.com/sashite/ggn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*.rb"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "json_schemer", "~> 2.4.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/ggn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/ggn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/ggn.rb",
    "source_code_uri"       => "https://github.com/sashite/ggn.rb",
    "specification_uri"     => "https://sashite.dev/documents/ggn/1.0.0/",
    "rubygems_mfa_required" => "true",
    "keywords"              => %w[chess game gameplay makruk notation pseudo-legal-move serialization shogi xiangqi].join(", ")
  }
end
