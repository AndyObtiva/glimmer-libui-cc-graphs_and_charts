# This line is only needed when running the example from inside the project directory
$LOAD_PATH.prepend(File.expand_path(File.join(__dir__, '..', '..', 'lib'))) if File.exist?(File.join(__dir__, '..', '..', 'lib'))

require 'glimmer-dsl-libui'
require 'glimmer/view/line_graph'

class BasicLineGraphRelative
  include Glimmer::LibUI::Application
  
  before_body do
    @start_time = Time.now
  end
  
  body {
    window('Basic Line Graph Relative', 900, 330) { |main_window|
      @line_graph = line_graph(
        width: 900,
        height: 300,
        graph_point_distance: :width_divided_by_point_count,
        lines: [
          {
            name: 'Feature A',
            stroke: [163, 40, 39, thickness: 2],
            x_value_start: @start_time,
            x_interval_in_seconds: 8,
            x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
            y_values: [80, 36, 10, 60, 20, 110, 16, 5, 36, 1, 77, 15, 3, 34, 8, 63, 12, 17, 90, 28, 70]
          },
          {
            name: 'Feature B',
            stroke: [47, 109, 104, thickness: 2],
            x_value_start: @start_time,
            x_interval_in_seconds: 8,
            x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
            y_values: [62, 0, 90, 0, 0, 27, 0, 56, 0, 0, 24, 0, 60, 0, 30, 0, 47, 0, 38, 90, 0]
          },
        ],
        display_attributes_on_hover: true,
      )
      
      on_content_size_changed do
        @line_graph.width = main_window.content_size[0]
        @line_graph.height = main_window.content_size[1] - 30
      end
    }
  }
end

BasicLineGraphRelative.launch
