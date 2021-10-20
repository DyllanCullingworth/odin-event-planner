# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(number)
  number = number.gsub(/[[:punct:] ]/, '')

  return number if number.length == 10
  return number[1..10] if number.length == 11 && number[0] == '1'

  'invalid'
end

def registration_hours(datetime, hours)
  time = Time.strptime(datetime, '%D %k:%M')
  hours[time.strftime('%k').to_i] += 1
end

def registration_days(datetime, days)
  date = Date.strptime(datetime, '%D')
  days[date.strftime('%a')] += 1
end

def peaks(hash)
  peaks = []
  hash.each do |k, v|
    peaks << k if v == hash.values.max
  end
  peaks
end


def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist? 'output'

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
reg_hours = Hash.new 0
reg_days = Hash.new 0

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  #   zipcode = clean_zipcode(row[:zipcode])
  #   phone_number = clean_phone_number(row[:homephone])
  #   legislators = legislators_by_zipcode(zipcode)
  #   form_letter = erb_template.result(binding)
  #
  #   save_thank_you_letter(id, form_letter)

  registration_date = row[:regdate]

  registration_hours(registration_date, reg_hours)
  registration_days(registration_date, reg_days)
end

peak_hours = peaks(reg_hours)
peak_days = peaks(reg_days)