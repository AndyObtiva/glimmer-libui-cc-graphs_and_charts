# TODO

- Show x-axis values in `bar_chart`
- Support non-Integer values for `line_graph` in relative mode
- Support showing grid marker lines with non-Integer values (when y-axis values are all less than 1 subdivide by fractions)
- Display the axis labels of the x-axis and y-axis in `line_graph`
- Display the axis labels of the x-axis and y-axis in `bar_chart`
- Display tooltips on hover in `line_graph`
- Display tooltips on hover in `bar_chart`
- Rename lines to series (spawning a new minor version)
- Reverse the order of y_values data (spawning a new minor version)
- Support more smart defaults to enable rendering a `line_graph` with the least amount of options possible (like not specifying any `x_value` options at all).
- Consider supporting custom controls like `table_and_line_graph` that would render data into a table and also visualize it in a `line_graph` above, below, or to the side of the `table`
- Consider the idea of supporting ChartKick's API syntax to provide familiar simple usage to Rails developers
- Support specifying min_x and max_x to start and end graph at (in case the user wants to see a different timeline from what the data strictly provides)
