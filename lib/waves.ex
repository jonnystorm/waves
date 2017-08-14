# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Waves do
  alias Waves.ViewPort

  def print_sine,
    do: print_sine([0, 2*:math.pi], [-1, 1])

  def print_sine(x_interval, y_interval, samples \\ 10000)
  def print_sine([x1,x2], [y1,y2], samples) do
    %{display_size: {80,24},
      x_interval: [x1,x2],
      y_interval: [y1,y2],
      samples: samples
    } |> print_function(&:math.sin/1)
  end

  def print_function(
    %{display_size: display_size,
      x_interval: [x1, x2],
      y_interval: [y1, y2],
      samples: samples
    },
    function
  )   when is_function(function)
  do
    display_size
    |> ViewPort.new({x1,y1}, {x2, y2})
    |> ViewPort.paint_function(function, samples)
    |> ViewPort.generate_character_grid(?*)
    |> ViewPort.print_character_grid
  end
end
