# This line is only needed when running the example from inside the project directory
$LOAD_PATH.prepend(File.expand_path(File.join(__dir__, '..', '..', 'lib'))) if File.exist?(File.join(__dir__, '..', '..', 'lib'))

require 'glimmer-dsl-libui'
require 'glimmer/view/bar_chart'

class BasicBarChart
  include Glimmer::LibUI::Application
  
  body {
    window('Basic Bar Chart', 900, 300) { |main_window|
      @bar_chart = bar_chart(
        width: 900,
        height: 300,
        x_axis_label: 'Month',
        y_axis_label: 'New Customer Accounts',
        values: {
          'Jan' => 30,
          'Feb' => 49,
          'Mar' => 58,
          'Apr' => 63,
          'May' => 72,
          'Jun' => 86,
          'Jul' => 95,
          'Aug' => 100,
          'Sep' => 84,
          'Oct' => 68,
          'Nov' => 52,
          'Dec' => 36,
        },
      )
      
      on_content_size_changed do
        @bar_chart.width = main_window.content_size[0]
        @bar_chart.height = main_window.content_size[1]
      end
    }
  }
end

BasicBarChart.launch
