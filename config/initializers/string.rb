class String
  def symbolize
    self.parameterize.downcase.underscore.to_sym
  end
end
