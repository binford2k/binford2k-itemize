# Update the interpolated string token to return a composed value string so we
# don't have to special case its handling. Because this is pre-compilation,
# we cannot resolve variables. So just tag w/ a marker
class Puppet::Pops::Model::ConcatenatedString
  def value
    segments.map {|t| t.value rescue nil }.join('<??>')
  end
end

# when a resource declaration title is just a variable
class Puppet::Pops::Model::VariableExpression
  def value
    '<??>'
  end
end

# when a resource reference is used
class Puppet::Pops::Model::AccessExpression
  def value
    keys.map {|t| t.value rescue nil }.join
  end
end

# when math (like a set operation) is used to generate a list of classes to use.
class Puppet::Pops::Model::ArithmeticExpression
  def value
    left_expr.value + operator + right_expr.value
  end
end

# when a postfix method generates a list of classes to declare
class Puppet::Pops::Model::CallMethodExpression
  def value
    '<??>'
  end
end

# when a function generates the name of a class to declare
class Puppet::Pops::Model::CallNamedFunctionExpression
  def value
    "#{functor_expr.value}(#{arguments.map {|a| a.value rescue nil }.join(',')})"
  end
end

# When someone uses a resource reference to ... declare a class with a default expression
# like ... who even does that?
class Puppet::Pops::Model::LiteralDefault
  def value
    '<??>'
  end
end
