require 'immutable_struct'


module Central
  class Event < ImmutableStruct.new(:id, :url, :title, :date, :instigator, :type)
    def id
      self[:id]
    end
    
    def [](p)
      v = super
      v = super(:url) if v.nil? && p.to_sym == :id
      v
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