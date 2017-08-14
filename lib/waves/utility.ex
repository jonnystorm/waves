# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Waves.Utility do
  @moduledoc false

  @type interval :: {number, number}
  @type range    :: Range.t

  @spec project_onto_naturals(
    number,
    interval,
    range
  ) :: integer | nil
  def project_onto_naturals(
    x,
    {a,b} = _interval,
    c..d  = _new_interval
  )   when a < x
       and     x < b
       and c != d
  do
    scalar = (d - c)/
             (b - a)

    offset = c - (scalar * a)

    trunc((scalar * x) + offset)
  end

  def project_onto_naturals(_, _, _),
    do: nil
end
