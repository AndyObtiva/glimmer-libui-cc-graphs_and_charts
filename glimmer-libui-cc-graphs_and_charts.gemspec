# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: glimmer-libui-cc-graphs_and_charts 0.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "glimmer-libui-cc-graphs_and_charts".freeze
  s.version = "0.4.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andy Maleh".freeze]
  s.date = "2025-02-23"
  s.description = "Graphs and Charts (Glimmer DSL for LibUI Custom Controls), like Line Graph, Bar Chart, and Bubble Chart.".freeze
  s.email = "andy.am@gmail.com".freeze
  s.extra_rdoc_files = [
    "CHANGELOG.md",
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "CHANGELOG.md",
    "LICENSE.txt",
    "README.md",
    "VERSION",
    "examples/graphs_and_charts/basic_bar_chart.rb",
    "examples/graphs_and_charts/basic_bubble_chart.rb",
    "examples/graphs_and_charts/basic_line_graph.rb",
    "examples/graphs_and_charts/basic_line_graph_relative.rb",
    "examples/graphs_and_charts/basic_line_graph_relative_reverse_x.rb",
    "examples/graphs_and_charts/basic_line_graph_reverse_x.rb",
    "glimmer-libui-cc-graphs_and_charts.gemspec",
    "lib/glimmer-libui-cc-graphs_and_charts.rb",
    "lib/glimmer/view/bar_chart.rb",
    "lib/glimmer/view/bubble_chart.rb",
    "lib/glimmer/view/line_graph.rb"
  ]
  s.homepage = "http://github.com/AndyObtiva/glimmer-libui-cc-graphs_and_charts".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.5.3".freeze
  s.summary = "Graphs and Charts (Glimmer DSL for LibUI Custom Controls)".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<glimmer-dsl-libui>.freeze, [">= 0.11.8".freeze, "< 2.0.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5.0".freeze])
  s.add_development_dependency(%q<juwelier>.freeze, ["= 2.4.9".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
end

