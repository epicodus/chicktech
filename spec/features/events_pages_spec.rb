require 'spec_helper'

feature "Creating events" do
  let(:admin) { FactoryGirl.create(:admin) }
  before { @city = FactoryGirl.create(:city) }

  scenario "with valid input" do
    sign_in(admin)
    visit new_event_path
    fill_in 'Name', with: 'Example event'
    fill_in 'Description', with: 'Example event description'
    fill_in 'event_start', with: 'December 25'
    fill_in 'event_finish', with: 'December 26'
    select  @city.name, from: 'event[city_id]'
    click_on "Create Event"
    expect(page).to have_content "successfully"
  end

  scenario "without valid input" do
    sign_in(admin)
    visit new_event_path
    click_on "Create Event"
    page.should have_content "blank"
  end

  scenario "not logged in as admin" do
    visit new_event_path
    page.should have_content "Access denied."
  end
end

feature "Listing events" do
  let(:volunteer) { FactoryGirl.create(:volunteer) }
  before { @city = FactoryGirl.create(:city) }

  scenario "with several events" do
    sign_in(volunteer)
    event_1 = FactoryGirl.create(:event, :city_id => @city.id)
    event_2 = FactoryGirl.create(:event, :city_id => @city.id)
    visit events_path
    page.should have_content event_1.name
    page.should have_content event_2.name
  end

  scenario "not signed in" do
    event_1 = FactoryGirl.create(:event, :city_id => @city.id)
    event_2 = FactoryGirl.create(:event, :city_id => @city.id)
    visit events_path
    page.should have_content "Access denied"
  end
end

feature "Adding a job" do
  scenario "signed in as admin" do
    admin = FactoryGirl.create(:admin)
    event = FactoryGirl.create(:event)
    sign_in(admin)
    visit event_path(event)
    page.should have_content "Add jobs"
  end
  
  scenario "signed in as volunteer", js: true do
    volunteer = FactoryGirl.create(:volunteer)
    event_1 = FactoryGirl.create(:event)
    event_2 = FactoryGirl.create(:event, city: event_1.city)
    sign_in(volunteer)
    select  event_1.city.name, from: 'city[city_id]'
    click_on 'Search'
    click_on(event_1.name)
    page.should_not have_content "Add jobs"
  end
end

feature "Adding a team" do
  context "as an admin" do
    let(:admin) { FactoryGirl.create(:admin) }

    it "page should have content 'Add a team'" do
      event = FactoryGirl.create(:event)
      sign_in(admin)
      visit event_path(event)
      page.should have_content "Add a team"
    end
  end

  context "as an event leader" do
    it "page should have content 'Add a team'" do
      event = FactoryGirl.create(:event)
      sign_in(event.leader)
      visit event_path(event)
      page.should have_content "Add a team"
    end
  end
end

feature "Unassigning an event leader" do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:volunteer) { FactoryGirl.create(:volunteer) }
  
  scenario "as an admin" do
    event = FactoryGirl.create(:event)
    leadership_role = FactoryGirl.create(:leadership_role, leadable: event, user: volunteer)
    sign_in(admin)
    visit event_path(event)
    page.should have_button "Unassign"
  end
end

feature "Signing up to be an Event Leader" do
  let(:volunteer) { FactoryGirl.create(:volunteer) }

  context "when there is no leader" do
    it "should have a button to become the leader" do
      sign_in(volunteer)
      @event = FactoryGirl.create(:event)
      @event.leadership_role.user_id = nil
      @event.leadership_role.save
      visit event_path(@event)
      page.should have_button('Take the lead!')
    end
  end

  context "when there is a leader" do
    before do
      sign_in(volunteer)
      @event = FactoryGirl.create(:event)
      @leadership_role = FactoryGirl.create(:leadership_role, leadable: @event)
      visit event_path(@event)
    end

    it "should not have a button to become the leader" do
      page.should_not have_button('Take the lead!')
    end

    it "should show the leader's name" do
      page.should have_content @event.leader.first_name
    end
  end
end

feature "Signing up for jobs" do
  let(:volunteer) { FactoryGirl.create(:volunteer) }
  let(:admin) { FactoryGirl.create(:admin) }
  
  scenario "signed in", js: true do
    job = FactoryGirl.create(:job) 
    sign_in(volunteer)
    select job.workable.city.name, from: 'city[city_id]'
    click_on 'Search'
    click_on(job.workable.name)
    page.should have_button "Sign Up!"
  end

  scenario "signing up for a job", js: true do
    job = FactoryGirl.create(:job) 
    sign_in(volunteer)
    select  job.workable.city.name, from: 'city[city_id]'
    click_on 'Search'
    click_on(job.workable.name)
    click_on "Sign Up!"
    page.should have_content "Congratulations"
  end

  scenario "job is already taken", js: true do
    job = FactoryGirl.create(:job) 
    sign_in(volunteer)
    visit event_path(job.workable)
    click_on "Sign Up!"
    page.should_not have_button "Sign Up!"
    page.should have_button "Resign!"
  end

  scenario "jobs are taken by other users", js: true do
    job = FactoryGirl.create(:job)
    sign_in(volunteer)
    select  job.workable.city.name, from: 'city[city_id]'
    click_on 'Search'
    click_on(job.workable.name)
    click_on "Sign Up!"
    click_on "Sign out"
    sign_in(admin)
    select  job.workable.city.name, from: 'city[city_id]'
    click_on 'Search'
    click_on(job.workable.name)
    page.should_not have_button "Sign Up!"
    page.should have_content "Taken by"
  end
end

feature "Showing all jobs on the page" do
  let(:volunteer) { FactoryGirl.create(:volunteer) }

  scenario "job is part of a team" do
    job = FactoryGirl.create(:team_job)
    sign_in(volunteer)
    visit team_path(job.workable)
    page.should_not have_content "No jobs have been created for this event"
  end
end
