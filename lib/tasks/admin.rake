namespace :admin do
  desc "Create superadmin user"
  task create_superadmin: :environment do
    email = 'teguhwmn189@superadmin.com'
    password = 'teguh123'
    
    if User.find_by(email: email)
      puts "Superadmin already exists with email: #{email}"
    else
      user = User.create!(
        email: email,
        password: password,
        password_confirmation: password,
        role: 'superadmin'
      )
      puts "Superadmin created successfully!"
      puts "Email: #{user.email}"
      puts "Role: #{user.role}"
    end
  end
end
