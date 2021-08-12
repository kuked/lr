require "test_helper"

class LrTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Lr::VERSION
  end

  def test_arithmetic_operation
    vm = Lr::VM.new
    assert_output("3.0\n") { vm.interpret("print 1 + 2;") }
    assert_output("0.0\n") { vm.interpret("print 1 + 2 - 3;") }
    assert_output("-9.0\n") { vm.interpret("print 1 + 2 - 3 * 4;") }
    assert_output("0.6000000000000001\n") { vm.interpret("print 1 + 2 - 3 * 4 / 5;") } # yuck :-<
    assert_output("9.0\n") { vm.interpret("print (1 + 2) * 3;") }
  end

  def test_boolean_operation
    vm = Lr::VM.new
    assert_output("true\n") { vm.interpret("print true;") }
    assert_output("false\n") { vm.interpret("print false;") }
    assert_output("true\n") { vm.interpret("print !false;") }
    assert_output("false\n") { vm.interpret("print !true;") }
  end
end
