Spec::Matchers.define :be_equivalent_to do |expected|
  def self.or(alternative)
    @alternative = alternative
    self
  end
  
  match do |actual|
    actual.to_s.gsub(/\s+/, ' ') == expected.to_s.gsub(/\s+/, ' ') ||
      actual.to_s.gsub(/\s+/, ' ') == @alternative.to_s.gsub(/\s+/, ' ')
  end
  
  failure_message_for_should do |actual|
    "expected\n#{actual.to_s}\nto be equivalent to\n#{expected.to_s}"
  end
  
  diffable
end
