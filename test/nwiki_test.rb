require 'test_helper'

class NwikiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Nwiki::VERSION
  end

  def test_it_does_something_useful
    assert "something useful"
  end
end