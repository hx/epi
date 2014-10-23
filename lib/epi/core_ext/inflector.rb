class String
  def camelize
    gsub(/(^|_)[a-z\d]/) { |m| m[-1].upcase }
  end
end

class Symbol
  def camelize
    to_s.camelize.to_sym
  end
end
