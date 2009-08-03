class PropertyDocument < Recliner::Document
  property :normal_property, String
  property :property_with_default_value, String, :default => 'the default'
  property :property_with_default_lambda_value, String, :default => lambda { 'hello' }
  property :property_with_default_lambda_value_yielding_doc, String, :default => lambda { |d| d.class.to_s }
  
  #property :nested do
  #  property :first, String
  #  property :second, String
  #end
  
  property :a_fixnum, Fixnum
  property :a_float, Float
  property :a_time, Time
  property :a_date, Date
  property :a_hash, Hash
  property :a_boolean, Boolean
  property :a_custom_class, MyCustomClass
end
