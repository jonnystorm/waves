defmodule Waves.Utility.Test do
  use ExUnit.Case

  import Waves.Utility

  test "Projects rationals onto the naturals" do
    assert project_onto_naturals(0.1, {0,10}, 0..10) == 0
    assert project_onto_naturals(  1, {0,10}, 0..10) == 1
    assert project_onto_naturals(  9, {0,10}, 0..10) == 9
    assert project_onto_naturals(9.9, {0,10}, 0..10) == 9
  end

  test "Projects rationals onto reversed naturals" do
    assert project_onto_naturals(0.1, {0,10}, 10..0) == 9
    assert project_onto_naturals(  1, {0,10}, 10..0) == 9
    assert project_onto_naturals(  9, {0,10}, 10..0) == 1
    assert project_onto_naturals(9.9, {0,10}, 10..0) == 0
  end

  test "Does not project interval bounds onto naturals" do
    assert project_onto_naturals( 0, {0,10}, 0..10) == nil
    assert project_onto_naturals(10, {0,10}, 0..10) == nil
  end

  test "Bug: projects certain rationals outside range" do
    rational = 2*:math.pi - 0.000000000000001
    interval = {0, 2*:math.pi}

    assert project_onto_naturals(rational, interval, 0..80)
      == 80
  end
end
