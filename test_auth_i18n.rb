#!/usr/bin/env ruby

# Test script for authentication i18n implementation

require_relative 'config/environment'

puts "=== Testing Authentication I18n Implementation ==="
puts

# Test ID locale
I18n.locale = :id
puts "🇮🇩 INDONESIAN LOCALE TESTS:"
puts "- Login title: #{I18n.t('auth.login.title')}"
puts "- Register title: #{I18n.t('auth.register.title')}"
puts "- Password reset title: #{I18n.t('auth.password_reset.title')}"
puts "- Sign in message: #{I18n.t('auth.messages.signed_in')}"
puts "- Sign up message: #{I18n.t('auth.messages.signed_up')}"
puts "- Invalid credentials: #{I18n.t('auth.messages.invalid')}"
puts

# Test EN locale
I18n.locale = :en
puts "🇺🇸 ENGLISH LOCALE TESTS:"
puts "- Login title: #{I18n.t('auth.login.title')}"
puts "- Register title: #{I18n.t('auth.register.title')}"
puts "- Password reset title: #{I18n.t('auth.password_reset.title')}"
puts "- Sign in message: #{I18n.t('auth.messages.signed_in')}"
puts "- Sign up message: #{I18n.t('auth.messages.signed_up')}"
puts "- Invalid credentials: #{I18n.t('auth.messages.invalid')}"
puts

# Test all auth keys exist in both locales
puts "=== Checking Translation Key Coverage ==="
auth_keys = [
  'auth.login.title',
  'auth.login.subtitle',
  'auth.login.email_label',
  'auth.login.password_label',
  'auth.login.submit_button',
  'auth.register.title',
  'auth.register.subtitle',
  'auth.register.email_label',
  'auth.register.password_label',
  'auth.register.submit_button',
  'auth.password_reset.title',
  'auth.password_reset.subtitle',
  'auth.password_edit.title',
  'auth.account_edit.title',
  'auth.confirmation.title',
  'auth.unlock.title',
  'auth.links.sign_in',
  'auth.links.sign_up',
  'auth.links.forgot_password',
  'auth.messages.signed_in',
  'auth.messages.signed_out',
  'auth.messages.signed_up',
  'auth.messages.invalid',
  'auth.messages.unauthenticated'
]

missing_keys = []

[:id, :en].each do |locale|
  I18n.locale = locale
  puts "\n🔍 Checking #{locale.upcase} locale:"
  
  auth_keys.each do |key|
    begin
      translation = I18n.t(key, raise: true)
      puts "  ✅ #{key}: '#{translation}'"
    rescue I18n::MissingTranslationData => e
      puts "  ❌ MISSING: #{key}"
      missing_keys << "#{locale}: #{key}"
    end
  end
end

if missing_keys.empty?
  puts "\n🎉 ALL AUTHENTICATION TRANSLATIONS ARE COMPLETE!"
else
  puts "\n⚠️  MISSING TRANSLATIONS:"
  missing_keys.each { |key| puts "  - #{key}" }
end

puts "\n=== Authentication I18n Test Complete ==="
