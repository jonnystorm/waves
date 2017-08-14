# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Waves.ViewPort do
  defstruct [
    :pixels,
    :resolution,
    :offset,
    :extent
  ]

  @type width_in_pixels  :: pos_integer
  @type height_in_pixels :: pos_integer
  @type min_x :: number
  @type min_y :: number
  @type max_x :: number
  @type max_y :: number

  @type t
    :: %__MODULE__{
      pixels: %{},
      resolution: {width_in_pixels, height_in_pixels},
      offset: {min_x, min_y},
      extent: {max_x, max_y}
    }

  alias Waves.Utility

  def new(
    {n,m} = resolution,
    {min_x, min_y} = offset,
    {max_x, max_y} = extent
  )   when is_integer(n)
       and is_integer(m)
       and n > 0
       and m > 0
       and min_x < max_x
       and min_y < max_y
  do
    pixels =
      for i <- 0..(m-1),
          j <- 0..(n-1),
          into: %{},
      do: {{i,j}, 0}

    %__MODULE__{
      pixels: pixels,
      resolution: resolution,
      offset: offset,
      extent: extent
    }
  end

  defp project_points_onto_pixel_indices(
    points,
    %{resolution: {n,m},
      offset: {min_x, min_y},
      extent: {max_x, max_y}
    } = _viewport
  ) do
    x_interval = {min_x, max_x}
    y_interval = {min_y, max_y}

    points
    |> Stream.map(fn {x,y} ->
      i = Utility.project_onto_naturals(y, y_interval, m..0)
      j = Utility.project_onto_naturals(x, x_interval, 0..n)

      i && j && {i,j}
    end)
    |> Stream.filter(& not is_nil &1)
  end

  defp set_pixel(
    %{resolution: {n,m}} = viewport,
    {i,j} = indices,
    value
  )   when i in 0..(m - 1)
       and j in 0..(n - 1)
       and is_number(value)
  do
    new_pixels =
      Map.replace(viewport.pixels, indices, value)

    %{viewport|pixels: new_pixels}
  end

  defp sample_function(xs, fun)
      when is_function(fun)
  do
    xs
    |> Stream.map(fn x ->
      try do
        {x, fun.(x)}
      rescue
        _ in ArithmeticError ->
          nil
      end
    end)
    |> Stream.filter(& not is_nil &1)
  end

  defp generate_sample_coordinates(
    sample_count,
    %{offset: {min_x, _},
      extent: {max_x, _}
    } = _viewport
  ) do
    x_step = (max_x - min_x) / sample_count

    0..sample_count
    |> Stream.map(& min_x + (&1 * x_step))
  end

  def paint_function(viewport, fun, sample_count)
      when is_function(fun)
       and is_integer(sample_count)
       and sample_count > 0
  do
    sample_count
    |> generate_sample_coordinates(viewport)
    |> sample_function(fun)
    |> project_points_onto_pixel_indices(viewport)
    |> clip_pixel_indices_to_viewport(viewport)
    |> paint_viewport(viewport)
  end

  defp clip_pixel_indices_to_viewport(
    indices,
    %{resolution: {n,m}} = _viewport
  ) do
    indices
    |> Stream.filter(fn {i,_} -> 0 <= i && i < m end)
    |> Stream.filter(fn {_,j} -> 0 <= j && j < n end)
  end

  defp paint_viewport(indices, viewport) do
    Enum.reduce indices, viewport,
      fn (indices, acc) ->
        set_pixel(acc, indices, 1)
      end
  end

  def generate_character_grid(
    %{resolution: {n,m}} = viewport,
    character_code
  )   when character_code in 0..255
  do
    for i <- 0..(m-1) do
      for j <- 0..(n-1) do
        if viewport.pixels[{i,j}] == 0,
          do: ?\s,
          else: character_code
      end
    end
  end

  def print_character_grid(grid) do
    Enum.map grid, fn row ->
      row
      |> :binary.list_to_bin
      |> IO.puts
    end

    :ok
  end
end
