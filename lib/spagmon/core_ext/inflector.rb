class String
  def camelize
    gsub(/(^|_)[a-z\d]/) { |m| m.upcase }
  end
end

class Symbol
  def camelize
    to_s.camelize.to_sym
  end
end
