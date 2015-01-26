require 'spec_helper'

feature 'project management', js: true do
  let(:user) { FactoryGirl.create :user }
  let(:project_name) { 'project name' }
  let(:new_valid_name) { 'new name' }
  let(:new_invalid_name) { ' ' }

  background do
    user.confirmed_at = Time.now
    user.save

    visit '/'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_on 'Log in'
  end

  feature 'project creation' do
    background do
      find('.new-project-button button').click
    end

    scenario 'user creates new project' do
      within '.new-project-form' do
        fill_in :name, with: project_name
        find('button.save').click
      end
      expect(find('.created-project .name')).to have_content(project_name)
    end

    scenario 'user fails to create new project due to validation' do
      within '.new-project-form' do
        fill_in :name, with: new_invalid_name
        find('button.save').click
      end
      expect(page).to have_no_selector '.created-project'
    end
  end

  context 'when user has project' do
    background do
      find('.new-project-button button').click
      within '.new-project-form' do
        fill_in 'name', with: project_name
        find('button.save').click
      end
    end

    scenario 'user deletes project' do
      find('.created-project .remove').click
      expect(page).to have_no_content project_name
    end

    feature 'project renaming' do
      scenario 'user changes project name' do
        expect {
          find('.created-project .edit').click
          within '.project-name-form' do
            fill_in :name, with: new_valid_name
            find('button.save').click
          end
        }.to change{ find('.created-project .name').text }.from(project_name).to(new_valid_name)
      end

      scenario 'user fails to change project name due to validation' do
        expect {
          find('.created-project .edit').click
          within '.project-name-form' do
            fill_in :name, with: new_invalid_name
            find('button.save').click
          end
        }.to_not change{ find('.created-project .name', visible: false).text }.from(project_name).to(new_invalid_name)
      end

      scenario 'user cancels project edition' do
        expect {
          find('.created-project .edit').click
          within '.project-name-form' do
            fill_in :name, with: new_invalid_name
          end
          find('.created-project .cancel').click
        }.to_not change{ find('.created-project .name', visible: false).text }
      end
    end
  end
end