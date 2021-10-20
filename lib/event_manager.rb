# frozen_string_literal: true

require 'csv'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])


  # if the zip code is exactly five digits, assume that it is ok
  # if the zip code is more than five digits, truncate it to the first five digits
  # if the zip code is less than five digits, add zeros to the front until it becomes five digits

  puts "#{name} #{zipcode}"
end

