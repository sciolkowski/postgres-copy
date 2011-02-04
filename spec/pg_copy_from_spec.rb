require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "COPY FROM" do
  before(:each) do
    ActiveRecord::Base.connection.execute %{
      TRUNCATE TABLE test_models;
      SELECT setval('test_models_id_seq', 1, false);
}
  end

  it "should import from file if path is passed without field_map" do
    TestModel.pg_copy_from File.expand_path('spec/fixtures/tab_with_header.csv')
    TestModel.order(:id).all.map{|r| r.attributes}.should == [{'id' => 1, 'data' => 'test data 1'}]
  end

  it "should import from IO without field_map" do
    TestModel.pg_copy_from File.open(File.expand_path('spec/fixtures/tab_with_header.csv'), 'r')
    TestModel.order(:id).all.map{|r| r.attributes}.should == [{'id' => 1, 'data' => 'test data 1'}]
  end

  it "should import with custom delimiter from path" do
    TestModel.pg_copy_from File.expand_path('spec/fixtures/semicolon_with_header.csv'), :delimiter => ';'
    TestModel.order(:id).all.map{|r| r.attributes}.should == [{'id' => 1, 'data' => 'test data 1'}]
  end

  it "should import with custom delimiter from IO" do
    TestModel.pg_copy_from File.open(File.expand_path('spec/fixtures/semicolon_with_header.csv'), 'r'), :delimiter => ';'
    TestModel.order(:id).all.map{|r| r.attributes}.should == [{'id' => 1, 'data' => 'test data 1'}]
  end

  it "should import and allow changes in block" do
    TestModel.pg_copy_from(File.open(File.expand_path('spec/fixtures/tab_with_header.csv'), 'r')) do |row|
      row[1] = 'changed this data'
    end
    TestModel.order(:id).all.map{|r| r.attributes}.should == [{'id' => 1, 'data' => 'changed this data'}]
  end
end

