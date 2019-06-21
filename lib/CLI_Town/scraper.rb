require_relative "../environment.rb"

require 'nokogiri'
require 'open-uri'

class Scraper

    def self.scrape_spell_list(spell_list)
      # empty info holders and html
      alpha = []
      spells = []
      alpha_book = {}
      spell_list_html = Nokogiri::HTML(open(spell_list))
      # scraping for :alpha (Spell A, B, C...)
      spell_list_html.css('h2').each {|segment| alpha << segment.text}
      alpha.each {|alpha| alpha_book[alpha] = []}
      # scraping for :name, :alpha, :url
      spell_list_html.css('li ul li').each_with_index do |spell, index|
        if index > 31
          name = spell.text
          url = "http://www.d20srd.org" + spell.css('a').attr('href').value
          alpha.each do |letter|
            if letter[-2] == name[0]
              assign = letter
              spells << {name: name, url: url, alpha: assign} unless spells.include?({name: name, url: url, alpha: assign})
            end
          end
        end
      end
      spells
    end

    def self.scrape_spell(spell)
      # empty info holders and html
      attributes = {list: [], level: [], description: []}
      descriptors = []
      stats = []
      description = []
      headers = []
      spell_html = Nokogiri::HTML(open(spell))
      # scraping for school, subschool if any, and descriptors if any
      spell_html.css('h4 a').each {|desc| descriptors << desc.text}
      descriptors = descriptors.compact
      attributes[:school] = descriptors[0]
      if descriptors.size == 2
        attributes[:descriptor] = descriptors[1]
      end
      if descriptors.size == 3
        attributes[:subschool] = descriptors[1]
        attributes[:descriptor] = descriptors[2]
      end
      # scraping for stat block
      spell_html.css('tr td').each {|stat| stats << stat.text}
      # seperating casting class and level
      if stats != []
        class_level = stats[0].split(/[\s,]/).delete_if {|stat| stat == ""}
      end
      # correcting for abbreviations, setting spell lists and levels
      # abbreviations list : bard Brd; cleric Clr; druid Drd; paladin Pal; ranger Rgr; sorcerer Sor; wizard Wiz.
      if class_level
        class_level.each_with_index do |stat, i|
          if stat == "Clr"
            attributes[:list] << "Cleric"
            attributes[:level] << class_level[i+1]
          elsif stat == "Brd"
            attributes[:list] << "Bard"
            attributes[:level] << class_level[i+1]
          elsif stat == "Drd"
            attributes[:list] << "Druid"
            attributes[:level] << class_level[i+1]
          elsif stat == "Pal"
            attributes[:list] << "Paladin"
            attributes[:level] << class_level[i+1]
          elsif stat == "Rgr"
            attributes[:list] << "Ranger"
            attributes[:level] << class_level[i+1]
          elsif stat == "Sor/Wiz"
            attributes[:list] << "Sorcerer"
            attributes[:level] << class_level[i+1]
            attributes[:list] << "Wizard"
            attributes[:level] << class_level[i+1]
          end
        end
      end
      # other stats
      attributes[:sr] = stats[-1]
      attributes[:saving_throw] = stats[-2]
      attributes[:duration] = stats[-3]
      attributes[:effect] = stats[-4]
      attributes[:range] = stats[-5]
      attributes[:cast_time] = stats[-6]
      attributes[:components] = stats[-7]
      #scraping for :description
      spell_html.css('p').each do |desc|
        description << desc.text
      end
      description.pop(3)
      description.each {|chunk| chunk.strip!}
      spell_html.css('h6').each do |header|
        headers << header.text
      end
      counter = 1
      until counter > headers.length
        description.insert(counter*-2, headers[-counter])
        counter += 1
      end
      description.each {|text| attributes[:description] << text}
      attributes
    end
    
  end