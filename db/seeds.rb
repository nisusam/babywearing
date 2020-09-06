# frozen_string_literal: true

require 'csv'
require 'uri'

include ActionView::Helpers::SanitizeHelper # included for strip_tags method to remove html from carrier descriptions

if Organization.count.zero?
  puts "Creating organizations..."
  Organization.create!(name: "Babywearing Admin", subdomain: "admin",
                      address: "update me", city: "Reston", state: "VA", zip: "20190",
                      email: "admin@example.com",
                       reply_email: "noreply@example.com")
  Organization.create!(name: "Mid-Atlantic Babywearing", subdomain: "midatlantic",
                      address: "update me", city: "Reston", state: "VA", zip: "20190",
                      email: "stephanie.funk@midatlanticbabywearing.org",
                       reply_email: "noreply@midatlanticbabywearing.org")
  Organization.create!(name: "Acme Babywearing", subdomain: "acme",
                      address: "123 Reve Street", city: "Dreamland", state: "MI", zip: "48080",
                      email: "dreamland@example.com",
                       reply_email: "noreply@example.com")
  puts "Done"
end

organization = Organization.find_by(subdomain: "midatlantic")

user_messages = []
if User.count.zero?
  puts "Creating default admin users..."
  admin_password = SecureRandom.alphanumeric(10)
  midatlantic_password = SecureRandom.alphanumeric(10)
  acme_password = SecureRandom.alphanumeric(10)
  email = "admin@example.com"

  User.create(email: email, password: admin_password,
              organization: Organization.find_by(subdomain: "admin"),
              first_name: "Seed", last_name: "User",
              street_address: "123 Hugo Street", city: "Hugo", state: "FL", postal_code: '33313',
              phone_number: "555-555-5555", role: 0)
  User.create(email: email, password: midatlantic_password,
              organization: organization,
              first_name: "Seed", last_name: "User",
              street_address: "123 Hugo Street", city: "Hugo", state: "FL", postal_code: '33313',
              phone_number: "555-555-5555", role: 0)
  User.create(email: email, password: acme_password,
              organization: Organization.find_by(subdomain: "acme"),
              first_name: "Seed", last_name: "User",
              street_address: "123 Hugo Street", city: "Hugo", state: "FL", postal_code: '33313',
              phone_number: "555-555-5555", role: 0)
  puts "Done."

  user_messages << "Users created:"
  user_messages << ""
  user_messages << "Subdomain          Username             Password"
  user_messages << "-----------------------------------------------------------------------------"
  user_messages << " 'admin'        '#{email}'  '#{admin_password}'"
  user_messages << " 'midatlantic'  '#{email}'  '#{midatlantic_password}'"
  user_messages << " 'acme'         '#{email}'  '#{acme_password}'"

end

ActsAsTenant.current_tenant = organization

if Agreement.count.zero?
  puts "Creating agreements..."

  admin = organization.users.where(role: :admin).first
  agreement = Agreement.create(name: 'Membership Agreement', organization: organization)
  agreement.versions.create(title: agreement.name, active: true, version: "1", last_modified_by: admin, content:
    'MidAtlantic Babywearing is the local babywearing education group for Pennsylvania, New Jersey, and Delaware,
     and is a non-profit group.

    To become a member of our chapter you must:
    1) Fill out the membership application and agreement.
    2) Pay your dues of $30/single carrier or $50/two carriers for 12 months or $10/one month trial by PayPal
    Membership Donation becomes active when application AND payment have been received.')

  agreement = Agreement.create(name: 'Lending Library Use Agreement', organization: organization)
  agreement.versions.create(title: agreement.name, active: true, version: "1", last_modified_by: admin, content:
      'MAB has a library of baby carriers and babywearing educational materials for members to borrow.

    The following policies apply:
    1. Your Responsibility. You assume the responsibility for safely using all carriers and for inspecting
    the stitching and fabric on all carriers to satisfy yourself that the carrier is sound and suitable for
    use with your child, and you assume the risk of using a carrier. Each time you borrow a carrier,
    you agree to indemnify and hold harmless MAB, its volunteers and members (the “Releasees”),
    for any harm that may result to you or your child from using the carrier, including any harm
    allegedly resulting from the Releasees’ instruction or alleged failure to instruct.')
end

if Category.count.zero?
  puts "Creating categories..."
  asian_inspired_carriers = Category.create(name: 'Asian Inspired Carriers')
  asian_inspired_carriers.subcategories << Category.create([
                                                             { name: 'Chuneis' }, { name: 'Hmongs' },
                                                             { name: 'Meh Dais / Bei Dais' },
                                                             { name: 'Onbuhimos' },
                                                             { name: 'Other Asian Inspired Carriers' },
                                                             { name: 'Podaegis' }
                                                           ])

  buckle_carriers = Category.create(name: 'Buckle Carriers')
  buckle_carriers.subcategories << Category.create([
                                                     { name: 'Full Buckle Carriers' },
                                                     { name: 'Half Buckle Carriers' },
                                                     { name: 'Other Buckle Carriers' },
                                                     { name: 'Ring Waist Carriers' },
                                                     { name: 'Reverse Half Buckle Carriers' }
                                                   ])

  Category.create([
                    { name: 'Carrier Accessories & Other' },
                    { name: 'Other Baby Carriers' },
                    { name: 'Pouch Carriers' },
                    { name: 'Water Baby Carriers' }
                  ])

  ring_slings = Category.create(name: 'Ring Slings')
  ring_slings.subcategories << Category.create([
                                                 { name: 'Gathered Ring Slings' },
                                                 { name: 'Hot Dog Ring Slings' },
                                                 { name: 'Hybrid Ring Slings' },
                                                 { name: 'Other Ring Slings' },
                                                 { name: 'Padded Ring Slings' },
                                                 { name: 'Pleated Ring Slings' }
                                               ])

  wrap_carriers = Category.create(name: 'Wrap Carriers')
  wrap_carriers.subcategories << Category.create([
                                                   { name: 'Hybrid Wrap Carriers' },
                                                   { name: 'Stretchy Wrap Carriers' },
                                                   { name: 'Woven Wrap Carriers' }
                                                 ])

  Category.create(name: 'Stretch Loop Carriers', parent_id: Category.find_by_name('Stretchy Wrap Carriers').id)
  Category.find_by_name('Woven Wrap Carriers').subcategories << Category.create([
                                                                                  { name: 'Chitenges' },
                                                                                  { name: 'Khangas' },
                                                                                  { name: 'Lesos' },
                                                                                  { name: 'Mantas' },
                                                                                  { name: 'Rebozos' }
                                                                                ])
  puts "Done."
end

if FeeType.count.zero?
  puts "Creating fee types..."
  FeeType.create(name: 'Cleaning Fee', organization: organization, fee_cents: 1500)
  FeeType.create(name: 'Late Fee', organization: organization, fee_cents: 100)
  FeeType.create(name: 'Membership Donation', organization: organization, fee_cents: 3000)
  FeeType.create(name: 'Second Carrier Addition',organization: organization, fee_cents: 500)
  FeeType.create(name: 'Trial Membership', organization: organization, fee_cents: 1000)
  puts "Done."
end

if Carrier.count.zero?
  puts "Importing carriers..."
  path = File.join Rails.root, 'db/data/inventory.csv'
  csv_text = File.read(path)
  csv = CSV.parse(csv_text, headers: true)

  csv.each do |row|
    csv_carrier = row.to_hash
    home_location = Location.find_or_create_by(name: csv_carrier['Home Location'], organization: organization)
    current_location = Location.find_or_create_by(name: csv_carrier['Current Location'], organization: organization)
    carrier_params = {
      item_id: csv_carrier['Item ID'],
      name: csv_carrier['Name'],
      manufacturer: csv_carrier['Manufacturer'],
      model: csv_carrier['Model'],
      color: csv_carrier['Color'],
      size: csv_carrier['Size'],
      home_location_id: home_location.id,
      current_location_id: (current_location || home_location).id,
      default_loan_length_days: csv_carrier['Default Loan Length'].to_i,
      category: Category.find_by(name: csv_carrier['Item Type'])
    }
    organization.carriers.create(carrier_params)
  end
  puts "Done."
end

if MembershipType.count.zero?
  puts "Creating default membership types..."

  MembershipType.create(name: "Annual", organization: organization, fee_cents: 5000, duration_days: 365, number_of_items: 3, short_name: "AN")
  MembershipType.create(name: "Monthly", organization: organization, fee_cents: 500, duration_days: 31, number_of_items: 1, short_name: "MO")
end

if ReminderEmailTemplate.count.zero?
  puts 'Creating reminder email templates...'

  ReminderEmailTemplate.create(name: "Due in one week", subject: "Carrier is due in one week", body:
      "Hello %USER_NAME%,
        <p>This is to remind you that your %CARRIER_NAME% is due on %DUE_DATE%.
        Please contact us if you anticipate any issues returning the carrier by the due date.</p>

        <p>Thank you,</p>

        Midatlantic Babywearing</p>", when_sent: 'before_due_date', when_days: 7, active: false)
  ReminderEmailTemplate.create(name: "Due today", subject: "Carrier is due TODAY", body:
      "Hello %USER_NAME%,
        <p>This is to remind you that your %CARRIER_NAME% is due TODAY.
        Please contact us if you anticipate any issues returning the carrier today.</p>

        <p>Thank you,</p>

        <p>Midatlantic Babywearing</p>", when_sent: 'on_due_date', when_days: 0, active: false)

  ReminderEmailTemplate.create(name: "Day Overdue", subject: "Carrier is overdue", body:
      "Hello %USER_NAME%,
        <p>This is to remind you that your %CARRIER_NAME% was due on %DUE_DATE% and is now OVERDUE.
        Please contact us as soon as possible let us know when you will be returning the carrier.</p>

        <p>Thank you,</p>

        <p>Midatlantic Babywearing</p>", when_sent: 'after_due_date', when_days: 1, active: false)

  ReminderEmailTemplate.create(name: "Week Overdue", subject: "Carrier is overdue", body:
      "Hello %USER_NAME%,
        <p>This is to remind you that your %CARRIER_NAME% was due on %DUE_DATE% and is now one week OVERDUE.
        Please contact us as soon as possible let us know when you will be returning the carrier.</p>

        <p>Thank you,</p>

        <p>Midatlantic Babywearing</p>", when_sent: 'after_due_date', when_days: 7, active: false)

end

if WelcomeEmailTemplate.count.zero?

  puts "Creating welcome email template..."

  WelcomeEmailTemplate.create(name: "Welcome", subject: "Welcome to Midatlantic Babywearing!", body:
        "<p>Welcome to Midatlantic Babywearing!</p>
        <p>We are so excited to have you join us. We hope you enjoy trying all the different carriers as
        much as we do. Our volunteers are ready to help guide, teach and support you on your babywearing journey.
       Feel free to reach out on facebook, email, or soon on our website.</p>", active: false
  )

end

if CheckoutEmailTemplate.count.zero?

  puts "Creating checkout email template..."

  CheckoutEmailTemplate.create(name: "Checkout", subject: "Midatlantic Babywearing Carrier Checkout", body:
      "<p>Thank you for checking out carrier %CARRIER_NAME% from Midatlantic Babywearing.</p>
      <p>The carrier is due on %DUE_DATE%.</p>
      <p>We will email you reminders before the carrier due date.</p>
      <p>Enjoy the carrier!</p>", active: false
  )

end

puts "Done with seeds."

user_messages.each { |m| puts m }
