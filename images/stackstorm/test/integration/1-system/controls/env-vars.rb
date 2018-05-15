# encoding: utf-8
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

control 'env-vars' do
  title 'Environment Variables'
  desc '
    Ensure that required environment variables, such as LC_ALL are defined correctly.
  '

  describe os_env('LC_ALL') do
    its('content') { should eq 'en_US.UTF-8' }
  end

  describe os_env('LANGUAGE') do
    its('content') { should eq 'en_US:en' }
  end

  describe os_env('LANG') do
    its('content') { should eq 'en_US.UTF-8' }
  end

  describe command('locale') do
    its('stdout') { should include 'en_US.UTF-8' }
  end
end
