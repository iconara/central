require 'immutable_struct'


module BurtCentral
  class Event < ImmutableStruct.new(:title, :date, :instigator, :url, :type)
    def <=>(other)
      self.date <=> other.date
    end
  end
end