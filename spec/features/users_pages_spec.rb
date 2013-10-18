require 'spec_helper'

feature 'Signing Up' do
  
  scenario 'with valid inputs' do
    superadmin = FactoryGirl.create(:superadmin)
    sign_in(superadmin)
    user = FactoryGirl.build(:volunteer)
    visit new_user_path
    fill_in 'First name', :with => user.first_name
    fill_in 'Last name', :with => user.last_name
    fill_in 'Phone', :with => user.phone
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    fill_in 'Password confirmation', :with => user.password_confirmation
    select user.role.humanize, :from => 'Role' 
    click_button "Sign up"
    page.should have_content 'successfully'
  end

  scenario "with no inputs" do
    superadmin = FactoryGirl.create(:superadmin)
    sign_in(superadmin)
    user = FactoryGirl.build(:volunteer)
    visit new_user_path
    click_button "Sign up" 
    page.should have_content 'blank'
  end

  scenario "with nonmatching password" do
    superadmin = FactoryGirl.create(:superadmin)
    sign_in(superadmin)
    user = FactoryGirl.build(:volunteer)
    visit new_user_path
    fill_in "Email", :with => user.email
    fill_in "Password", :with => user.password
    fill_in "Password confirmation", :with => "foobar"
    click_button "Sign up" 
    page.should have_content 'match'
  end

  context "when not signed in as a superadmin" do
    it "should not have a 'sign up' link" do
      user = FactoryGirl.build(:volunteer)
      sign_in(user)
      visit root_path
      page.should_not have_content "Sign up"
    end

    it 'should block access to signing up' do
      user = FactoryGirl.build(:admin)
      sign_in(user)
      visit new_user_path
      page.should have_content "Access denied"
    end
  end

  context "when signed in as superadmin" do
    it "should keep you signed in after adding a new user" do
      superadmin = FactoryGirl.create(:superadmin)
      volunteer = FactoryGirl.build(:volunteer)
      sign_in(superadmin)
      visit new_user_path
      fill_in 'First name', :with => volunteer.first_name
      fill_in 'Last name', :with => volunteer.last_name
      fill_in 'Phone', :with => volunteer.phone
      fill_in 'Email', :with => volunteer.email
      fill_in 'Password', :with => volunteer.password
      fill_in 'Password confirmation', :with => volunteer.password_confirmation
      select volunteer.role.humanize, :from => 'Role' 
      click_button "Sign up"
      page.should have_content superadmin.first_name
    end
  end
end

feature "Signing in" do

  scenario "with correct information" do
    user = FactoryGirl.create(:volunteer)
    visit '/users/sign_in'
    fill_in "Email", :with => user.email
    fill_in "Password", :with => user.password
    click_button "Sign in" 
    page.should have_content 'successfully'
  end

  scenario "with incorrect information" do
    user = FactoryGirl.create(:volunteer)
    visit '/users/sign_in'
    fill_in "Email", :with => user.email
    click_button "Sign in" 
    page.should have_content 'Invalid'
  end
end

feature "'Manage Volunteers' link" do
  scenario "Superadmin is signed in" do
    superuser = FactoryGirl.create(:superadmin)
    visit '/users/sign_in'
    fill_in "Email", :with => superuser.email
    fill_in "Password", :with => superuser.password
    click_button "Sign in" 
    page.should have_content 'Manage Volunteers'
  end
  scenario "when Admin is signed in" do
    admin = FactoryGirl.create(:admin)
    visit '/users/sign_in'
    fill_in "Email", :with => admin.email
    fill_in "Password", :with => admin.password
    click_button "Sign in"
    page.should_not have_content 'Manage Volunteers'
  end
  scenario "when no one is signed in" do
    visit root_path
    page.should_not have_content 'Manage Volunteers'
  end
end

feature "'Manage Events' link" do
  scenario "when Admin is signed in" do
    admin = FactoryGirl.create(:admin)
    visit '/users/sign_in'
    fill_in "Email", :with => admin.email
    fill_in "Password", :with => admin.password
    click_button "Sign in"
    page.should have_content 'Manage Events'
  end
  scenario "Superadmin is signed in" do
    superuser = FactoryGirl.create(:superadmin)
    visit '/users/sign_in'
    fill_in "Email", :with => superuser.email
    fill_in "Password", :with => superuser.password
    click_button "Sign in" 
    page.should have_content 'Manage Events'
  end
end

feature "Invite a user link" do
  scenario "Superadmin is signed in" do
    superuser = FactoryGirl.create(:superadmin)
    sign_in(superuser)
    visit users_path
    page.should have_content 'Invite a new user'
  end
end

feature "deleting a user" do
  scenario "superadmin is able to delete user" do
    superadmin = FactoryGirl.create(:superadmin)
    sign_in(superadmin)
    volunteer = FactoryGirl.create(:volunteer)
    visit users_path
    click_link "remove#{volunteer.id}"
    visit users_path
    page.should_not have_content volunteer.first_name
  end

  scenario "user is able to delete itself" do
    volunteer = FactoryGirl.create(:volunteer)
    sign_in(volunteer)
    visit users_path
    click_link "remove#{volunteer.id}"
    page.should_not have_content volunteer.first_name
  end
end

feature "updating a user" do
  scenario "superadmin is able to update a user" do
    superadmin = FactoryGirl.create(:superadmin)
    sign_in(superadmin)
    volunteer = FactoryGirl.create(:volunteer)
    visit user_path(volunteer)
    click_link "Edit"
    fill_in "Phone", with: "111"
    click_button "Update"
    page.should have_content "updated"
  end
end

feature "changing password" do
  scenario "logged in user is able to access change password form" do
    volunteer = FactoryGirl.create(:volunteer)
    sign_in(volunteer)
    visit change_password_path
    page.should have_content "Change Password"
  end

  scenario "logged in user is able to change their password" do 
    volunteer = FactoryGirl.create(:volunteer)
    sign_in(volunteer)
    visit change_password_path
    fill_in "Password", with: "spellsRkool"
    fill_in "Password confirmation", with: "spellsRkool"
    fill_in "Current password", with: volunteer.password
    click_button "Update"
    page.should have_content "successfully"
  end
end



  # scenario "logged in user is able to change their password" do
  #   volunteer = FactoryGirl.create(:volunteer)
  #   sign_in






