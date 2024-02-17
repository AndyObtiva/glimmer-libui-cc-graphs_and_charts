# This line is only needed when running the example from inside the project directory
$LOAD_PATH.prepend(File.expand_path(File.join(__dir__, '..', '..', 'lib'))) if File.exist?(File.join(__dir__, '..', '..', 'lib'))

require 'glimmer-dsl-libui'
require 'glimmer/view/bubble_chart'

class BasicBubbleChart
  include Glimmer::LibUI::Application
  
  body {
    window('Basic Line Graph', 900, 300) { |main_window|
      @bubble_chart = bubble_chart(
        width: 900,
        height: 300,
        fill: [163, 40, 39],
        values: {
          Time.new(2030, 12, 1, 13, 0, 0) => {
            1 => 4,
            2 => 8,
            8 => 3,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 2) => {
            1 => 1,
            2 => 5,
            7 => 1,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 4) => {
            1 => 2,
            2 => 3,
            4 => 4,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 6) => {
            1 => 7,
            2 => 1,
            7 => 7,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 8) => {
            1 => 6,
            2 => 8,
            8 => 1,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 10) => {
            1 => 1,
            2 => 1,
            3 => 9,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 12) => {
            1 => 5,
            2 => 12,
            5 => 17,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 14) => {
            1 => 9,
            2 => 2,
            6 => 10,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 16) => {
            1 => 0,
            2 => 5,
            7 => 8,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 18) => {
            1 => 9,
            3 => 3,
            5 => 6,
            10 => 0
          },
          Time.new(2030, 12, 1, 13, 0, 20) => {
            2 => 2,
            4 => 4,
            7 => 7,
            10 => 0
          },
        },
        x_value_format: -> (time) {time.strftime('%M:%S')},
      )
      
      on_content_size_changed do
        @bubble_chart.width = main_window.content_size[0]
        @bubble_chart.height = main_window.content_size[1]
      end
    }
  }
end

BasicBubbleChart.launch
