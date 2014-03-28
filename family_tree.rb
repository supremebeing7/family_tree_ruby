require 'bundler/setup'
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def menu
  puts 'Welcome to the family tree!'
  puts 'What would you like to do?'

  loop do
    puts 'Press a to add a family member.'
    puts 'Press l to list out the family members.'
    puts 'Press m to add who someone is married to.'
    puts 'Press s to see relatives of a person.'
    puts 'Press e to exit.'
    choice = gets.chomp

    case choice
    when 'a'
      add_person
    when 'l'
      list
    when 'm'
      add_marriage
    when 's'
      pick_family_member
    when 'e'
      exit
    end
  end
end

def add_person
  puts 'What is the name of the family member?'
  name = gets.chomp
  person = Person.create(:name => name)
  puts "Add parents? (Y/N)"
  if gets.chomp.upcase == 'Y'
    add_parents(person)
  end
  puts name + " was added to the family tree.\n\n"
end

def add_marriage
  list
  puts 'What is the number of the first spouse?'
  spouse1 = Person.find(gets.chomp)
  puts 'What is the number of the second spouse?'
  spouse2 = Person.find(gets.chomp)
  spouse1.update(:spouse_id => spouse2.id)
  puts spouse1.name + " is now married to " + spouse2.name + "."
end

def add_parents(person)
  list
  puts "Enter the number of the first parent:\n"
  print ">"
  parent1 = Person.find(gets.chomp)
  puts "Enter the number of the second parent:\n"
  print ">"
  parent2 = Person.find(gets.chomp)
  person.update(:parent1_id => parent1.id, :parent2_id => parent2.id)
  puts "#{person.name} is the kid of #{parent1.name} and #{parent2.name}"
end

def list
  puts "Here are all your relatives:\n"
  people = Person.all
  people.each do |person|
    puts "#{person.id.to_s}: #{person.name}"
  end
  puts "\n"
end

def pick_family_member
  list
  puts "\n\nEnter the number of the relative and I'll show you who they're related to."
  person = Person.find(gets.chomp)

  show_marriage(person)
  show_siblings(person)
  show_nieces_and_nephews(person)
  show_descendants(person)
  show_ancestors(person)
end

def show_marriage(person)
  if person.spouse_id == nil
    puts "#{person.name} is unmarried."
  else
    spouse = Person.find(person.spouse_id)
    puts "#{person.name} is married to #{spouse.name}."
  end
rescue
  puts "Oops. Something went wrong with the show_marriage function."
end

def show_descendants(person, generation=0)
  unless person.kids.nil?
    if generation == 0
      puts "Children:"
    elsif generation == 1
      puts "Grandchildren:"
    else
      puts ("Great " * (generation - 2)) + "grandchildren:"
    end
    next_generation = generation + 1
    person.kids.each { |kid| puts kid.name }
    person.kids.each { |kid| show_nieces_and_nephews(kid, next_generation)}
    person.kids.each { |kid| show_descendants(kid, next_generation) }
  end
end

def show_ancestors(person, generation=0)
  unless person.parents.nil?
    if generation == 0
      puts "Parents:"
    elsif generation == -1
      puts "Grandparents:"
    else
      puts ("Great " * (generation + 2)) + "grandparents:"
    end
    previous_generation = generation - 1
    person.parents.each { |parent| puts parent.name }
    person.parents.each { |parent| show_siblings(parent, previous_generation) }
    person.parents.each { |parent| show_ancestors(parent, previous_generation) }
  end
end

def show_siblings(person, generation=0)
  # puts person.name
  unless person.siblings.nil?
    if generation == 0
      puts "Siblings:"
    elsif generation == -1
      puts "Uncles/Aunts:"
    elsif generation <= -2
      puts ("Great " * (generation + 2)) + "uncles/aunts:"
    end
    person.siblings.each { |sibling| puts sibling.name }
  end
end

def show_nieces_and_nephews(person, generation=0)
  unless person.nieces_and_nephews.nil?
    if generation == 0
      puts "Nieces/Nephews:"
    elsif generation == 1
      puts "Grand nieces/nephews:"
    elsif generation > 1
      puts ("Great " * (generation + 2)) + "grandnieces/grandnephews:"
    end
    person.nieces_and_nephews.each { |n| puts n.name }
  end
end

menu
