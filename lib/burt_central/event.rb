require 'immutable_struct'


module BurtCentral
  class Event < ImmutableStruct.new(:url, :title, :date, :instigator, :type)
    def <=>(other)
      self.date <=> other.date
    end
    
    def to_h
      members.inject({:_id => url}) do |h, m|
        h[m.to_sym] = self[m]
        h
      end
    end
  end
end