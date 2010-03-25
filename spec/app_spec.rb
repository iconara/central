require File.expand_path('../spec_helper', __FILE__)


describe 'Burt Central Webapp' do
  
  include Capybara
  
  before(:all) do
    Capybara.app = App
    Capybara.default_driver = :selenium
    
    @configuration = BurtCentral::Configuration.new({:database => 'burt_central'}, :test)
    @events_collection = @configuration.events_collection

    @events_collection.remove

    @events_collection.save({
      :_id => 'http://example.com/a',
      :title => 'The message is a massage',
      :url => 'http://example.com/a',
      :instigator => 'Mike',
      :date => Time.now,
      :type => :rambling
    })
    @events_collection.save({
      :_id => 'http://example.com/b',
      :title => 'All good things come to a beginning',
      :url => 'http://example.com/b',
      :instigator => 'Phil',
      :date => Time.now - (12 * 60 * 60),
      :type => :nonsense
    })
  end
  
  after(:all) do
    @events_collection.remove
  end
  
  before do
    visit('/index.html')
  end
  
  it 'loads events and displays them' do
    page.should have_content('The message is a massage')
    page.should have_content('All good things come to a beginning')
  end
  
  it 'creates a legend from the event types' do
    page.should have_content('rambling')
    page.should have_content('nonsense')
  end
  
end