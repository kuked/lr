require "test_helper"

class LrTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Lr::VERSION
  end

  def test_arithmetic_operation
    vm = Lr::VM.new
    assert_output("3\n") { vm.interpret("print 1 + 2;") }
    assert_output("0\n") { vm.interpret("print 1 + 2 - 3;") }
    assert_output("-9\n") { vm.interpret("print 1 + 2 - 3 * 4;") }
    assert_output("0.6\n") { vm.interpret("print 1 + 2 - 3 * 4 / 5;") }
    assert_output("9\n") { vm.interpret("print (1 + 2) * 3;") }
  end

  def test_boolean_operation
    vm = Lr::VM.new
    assert_output("true\n") { vm.interpret("print true;") }
    assert_output("false\n") { vm.interpret("print false;") }
    assert_output("true\n") { vm.interpret("print !false;") }
    assert_output("false\n") { vm.interpret("print !true;") }
  end

  def test_compare_operation
    vm = Lr::VM.new
    assert_output("true\n") { vm.interpret("print 1 == 1;") }
    assert_output("true\n") { vm.interpret("print 1 != 2;") }
    assert_output("true\n") { vm.interpret("print 2 < 3;") }
    assert_output("true\n") { vm.interpret("print 3 <= 4;") }
    assert_output("false\n") { vm.interpret("print 3 < 2;") }
    assert_output("false\n") { vm.interpret("print 4 <= 3;") }
    assert_output("true\n") { vm.interpret("print 3 > 2;") }
    assert_output("true\n") { vm.interpret("print 4 >= 3;") }
    assert_output("false\n") { vm.interpret("print 2 > 3;") }
    assert_output("false\n") { vm.interpret("print 3 >= 4;") }
  end

  def test_global_variable
    vm = Lr::VM.new
    script = 'var a = "a"; var b = "b"; a = "a with " + b; print a;'
    assert_output("a with b\n") { vm.interpret(script) }
  end

  def test_local_variable
    vm = Lr::VM.new
    script = "{ var a = 1; { var a = 2; print a; } }"
    assert_output("2\n") { vm.interpret(script) }
  end
end
