module BurtCentral
  module Sources
    class Highrise
      include Logging
      
      def events(since)
        logger.info('Loading Highrise users')

        users = ::Highrise::User.find(:all)
        users_by_id = users.inject({}) { |h, user| h[user.id] = user; h }

        logger.info('Loading Highrise cases')

        cases = ::Highrise::Kase.find(:all, :from => :open)

        logger.info('Loading Highrise notes')

        notes = cases.inject([]) do |notes, c|
          notes += c.notes(:since => since.strftime('%Y%m%d'))
          notes
        end

        #<Highrise::User:0x104b83760 @attributes={"name"=>"Axel von Sydow", "created_at"=>Sat Jun 13 09:21:30 UTC 2009, "updated_at"=>Sat Jun 13 09:21:30 UTC 2009, "id"=>155735, "email_address"=>"axel@byburt.com"}, @prefix_options={}>
        #<Highrise::Kase:0x104b80a38 @attributes={"name"=>"Advertiser customer development", "created_at"=>Wed Jan 20 21:36:31 UTC 2010, "background"=>nil, "updated_at"=>Thu Aug 27 14:07:45 UTC 2009, "group_id"=>nil, "id"=>203730, "owner_id"=>nil, "closed_at"=>nil, "visible_to"=>"Everyone", "author_id"=>nil}, @prefix_options={}>
        #<Highrise::Note:0x104b07570 @attributes={"created_at"=>Thu Aug 27 14:07:45 UTC 2009, "body"=>"Held one hour talk …", "updated_at"=>Wed Jan 20 21:36:31 UTC 2010, "group_id"=>nil, "id"=>14236161, "owner_id"=>nil, "subject_id"=>203730, "collection_type"=>"Kase", "subject_type"=>"Kase", "visible_to"=>"Everyone", "author_id"=>104692, "subject_name"=>"Advertiser customer development", "collection_id"=>203730}, @prefix_options={}>

        host = ::Highrise::Base.site.host
        
        notes.map do |note|
          Event.new(
            :title => note.subject_name,
            :date => note.updated_at,
            :instigator => users_by_id[note.author_id].name,
            :url => "https://#{host}/notes/#{note.id}",
            :type => :case_note
          )
        end
      rescue
        logger.warn("Could not load case notes: #{$!}")
        []
      end
    end
  end
end