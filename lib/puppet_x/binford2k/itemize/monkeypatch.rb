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
