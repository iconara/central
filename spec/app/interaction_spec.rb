require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../spec_helper', __FILE__)


describe 'Central Webapp User Interaction' do
  
  before do
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
    
    @session = Capybara::Session.new(:selenium, App)
    @session.visit('/index.html')
  end

  context 'when not logged in' do
    it 'shows a log in form' do
      @session.should have_content('Password')
      @session.should have_css('input[type=password]')
    end
  end

  context 'when logged in' do
    before do
      if @session.find(:css, '#login-form').visible?
        @session.fill_in('Password', :with => 'password')
        @session.click('Ok')
      end
    end
  
    it 'loads events and displays them' do
      @session.should have_content('The message is a massage')
      @session.should have_content('All good things come to a beginning')
    end

    it 'creates a legend from the event types' do
      @session.should have_content('rambling')
      @session.should have_content('nonsense')
    end
  end
  
end