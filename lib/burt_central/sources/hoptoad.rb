module BurtCentral
  module Sources
    class Hoptoad
      include Logging
      
      def events(since)
        logger.info('Loading Hoptoad errors')

        errors = ::Hoptoad::Error.find(:all)

        #<Hoptoad::Error:0x104b260b0 @attributes={"notice_hash"=>"1d6097ad97f1bffa1bcbbbfb898ff81d", "created_at"=>Thu Jan 21 02:38:49 UTC 2010, "project_id"=>7597, "updated_at"=>Wed Mar 10 08:57:52 UTC 2010, "action"=>nil, "notices_count"=>65, "resolved"=>false, "id"=>1231518, "lighthouse_ticket_id"=>nil, "error_message"=>"ActionController::MethodNotAllowed: Only put requests are allowed.", "error_class"=>"ActionController::MethodNotAllowed", "controller"=>nil, "rails_env"=>"production", "file"=>"[GEM_ROOT]/gems/actionpack-2.3.5/lib/action_controller/routing/recognition_optimisation.rb", "most_recent_notice_at"=>Wed Mar 10 08:58:16 UTC 2010, "line_number"=>64}, @prefix_options={}>

        errors.select { |error|
          error.most_recent_notice_at.to_date >= since
        }.map { |error|
          Event.new(
            :title => error.error_message,
            :date => error.most_recent_notice_at,
            :instigator => nil,
            :url => "http://burt.hoptoadapp.com/errors/#{error.id}",
            :type => :error
          )
        }
      rescue
        logger.warn("Could not load errors: #{$!}")
        []
      end
      
    end
  end
end