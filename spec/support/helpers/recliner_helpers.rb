module ReclinerHelpers
  def save_with_stubbed_database(subject)
    @database = mock('database', :put => { 'id' => 'document-id', 'rev' => '1-12345' })
    subject.stub!(:database).and_return(@database)
  
    subject.save
  end
  
  def save_with_stubbed_database!(subject)
    @database = mock('database', :put => { 'id' => 'document-id', 'rev' => '1-12345' })
    subject.stub!(:database).and_return(@database)
  
    subject.save!
  end
end
