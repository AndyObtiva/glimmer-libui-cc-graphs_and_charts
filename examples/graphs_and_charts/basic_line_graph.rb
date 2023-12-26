# This line is only needed when running the example from inside the project directory
$LOAD_PATH.prepend(File.expand_path(File.join(__dir__, '..', '..', 'lib'))) if File.exist?(File.join(__dir__, '..', '..', 'lib'))

require 'glimmer-dsl-libui'
require 'glimmer/view/line_graph'

class BasicLineGraph
  include Glimmer::LibUI::Application
  
  body {
    window('Basic Line Graph', 900, 300) { |main_window|
      @line_graph = line_graph(
        width: 900,
        height: 300,
        lines: [
          {
            name: 'Stock 1',
            stroke: [163, 40, 39, thickness: 2],
            values: {
              Time.new(2030, 12, 1) => 2,
              Time.new(2030, 12, 2) => 2.5,
              Time.new(2030, 12, 4) => 1,
              Time.new(2030, 12, 5) => 0,
              Time.new(2030, 12, 6) => 2,
            },
            x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
          },
          {
            name: 'Stock 2',
            stroke: [47, 109, 104, thickness: 2],
            values: {
              Time.new(2030, 12, 1) => 2,
              Time.new(2030, 12, 2) => 0,
              Time.new(2030, 12, 3) => 2.5,
              Time.new(2030, 12, 5) => 1,
              Time.new(2030, 12, 7) => 2,
            },
            x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
          },
        ],
      )
      
      on_content_size_changed do
        @line_graph.width = main_window.content_size[0]
        @line_graph.height = main_window.content_size[1]
      end
    }
  }
end

BasicLineGraph.launch
