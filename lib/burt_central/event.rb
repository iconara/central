require 'immutable_struct'


module BurtCentral
  class Event < ImmutableStruct.new(:id, :url, :title, :date, :instigator, :type)
    def id
      self[:id] || self[:url]
    end
    
    def <=>(other)
      self.date <=> other.date
    end
    
    def eql?(other)
      other.respond_to?(:id) && other.id == self.id
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