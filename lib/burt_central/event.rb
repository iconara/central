require 'immutable_struct'


module BurtCentral
  class Event < ImmutableStruct.new(:url, :title, :date, :instigator, :type)
    def <=>(other)
      self.date <=> other.date
    end
    
    def eql?(other)
      other.respond_to?(:url) && other.url == self.url
    end
    alias_method :==, :eql?
    
    def to_h
      members.inject({}) do |h, m|
        h[m.to_sym] = self[m]
        h
      end
    end
  end
end