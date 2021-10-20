puts 'Event Manager Initialized!'

# Read the file contents
file = 'event_attendees.csv'

if File.exists? file
  lines = File.readlines(file)

  lines.each_with_index do |line, index|
    next if index == 0
    columns = line.split(',')
    name = columns[2]
    puts "First Name:  #{name}"
  end
end