# Change Log

## 0.2.2

- Fix issue with `bar_chart` vertical scaling of grid markers when numbers are larger than 1000 and have `K` in them by disabling `K` formatting for now (the issue was seeing the same marker number twice because two consecutive markers were calculated with similar shortened values; e.g. both 10K when one is 10100 and the other is 10750).

## 0.2.1

- Fix clipped text of grid markers when they include 1000 displayed as 1K

## 0.2.0

- Initial implementation of `bar_chart` custom control
- New `examples/graphs_and_charts/basic_bar_chart.rb`

## 0.1.8

- Fix the display of grid marker lines when passing `values` with non-Integer y-axis values (especially max y-axis value being non-Integer). It now shows highest grid marker having a non-Integer value while keeping smaller values as Integer (e.g. 1, 2, 3, 3.75).

## 0.1.7

- Scale `y` axis when using `values` option to fill up the vertical graph height if all y-axis values are smaller than `1`

## 0.1.6

- Support passing line `values` as a `Hash` map of x-axis values to y-axis values instead of using the combination of `y_values`, `x_value_start`, and `x_interval_in_seconds`
- Rename `examples/graphs_and_charts/basic_line_graph.rb` to `examples/graphs_and_charts/basic_line_graph_relative.rb`
- New `examples/graphs_and_charts/basic_line_graph.rb` (replacing older example that got renamed to `basic_line_graph_relative.rb`)
- Add graph auto-scaling logic to both `examples/graphs_and_charts/basic_line_graph.rb` & `examples/graphs_and_charts/basic_line_graph_relative.rb`

## 0.1.5

- Render circles for every point in addition to the lines connecting all the points
- Render a single point if there is only 1 value in `lines` `y_values` instead of rendering nothing until 2 values exist at least
- Support `graph_point_radius`, `graph_selected_point_radius`, and `graph_fill_selected_point` options for customizing the circle of every rendered point and selected point.
- Avoid rendering on top of the grid markers on the left side
- Optimize performance of rendering grid markers and showing mouse hover selection stats of a point

## 0.1.4

- Fix issue with crashing at `lib/glimmer/view/line_graph.rb:243:in y_value_max_for_all_lines': undefined method max for nil:NilClass`

## 0.1.3

- Fix issue with crashing if lines had points that did not share the same x-axis values as opposed to all points in all lines falling on the same x-axis values

## 0.1.2

- Fix issue with crashing if the mouse hovers over a graph without any points yet

## 0.1.1

- Ensure that `line_graph` max `y_value` is taken into account in visible points only (excluding points outside the visible area)
- Support ability to load entire `'glimmer-libui-cc-graphs_and_charts'` library instead of individual graphs/charts if preferred
- New `examples/graphs_and_charts/basic_line_graph.rb`

## 0.1.0

- Initial implementation of `line_graph` custom control
