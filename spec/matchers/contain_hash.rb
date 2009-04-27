Spec::Matchers.define :contain_hash do |expected|
  match do |actual|
    expected.all? do |key, value|
      actual[key] == value
    end
  end
end
