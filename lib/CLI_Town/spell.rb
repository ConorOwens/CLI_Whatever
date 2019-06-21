class Spell
  
attr_accessor :name, :list, :level, :school, :subschool, :descriptor, :components, :cast_time, :range, :effect, :duration, :saving_throw, :sr, :description, :alpha, :url

  @@all = []

  def initialize(spell_base)
    spell_base.each {|key, value| self.send(("#{key}="), value)}
    @@all << self
  end

  def self.create_from_collection(spell_list)
    spell_list.each {|spell_hash| Spell.new(spell_hash)}
  end

  def add_spell_attributes(attributes_hash)
    attributes_hash.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.all
    @@all
  end
  
end