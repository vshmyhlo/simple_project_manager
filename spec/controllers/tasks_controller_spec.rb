require 'spec_helper'

describe TasksController do
  include_context 'valid session'

  let(:valid_attributes) { { "name" => "valid name" } }
  let(:invalid_attributes) { { "name" => "s" } }

  let(:valid_session) { {} }
  let(:user) { FactoryGirl.create :user }

  before :each do
    user.confirmed_at = Time.now
    user.save
    sign_in user
  end

  # TODO: rewrite this
  it "raises RecordNotFound" do
    expect {
      get :show, { id: 1 }, valid_session
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
  # ====================================================================================================================
  describe "GET index" do
    let(:project) { user.projects.create valid_attributes }

    before :each do
      get :index, {}, valid_session
    end

    it "assigns all projects as @projects" do
      expect(assigns(:projects)).to include(project)
    end

    it "renders the index.json template" do
      expect(response).to render_template('index.json')
    end

    it "is successful" do
      expect(response.status).to eq(200)
    end
  end
  # ====================================================================================================================
  describe "GET show" do
    let(:project) { user.projects.create valid_attributes }

    before :each do
      get :show, {id: project.to_param}, valid_session
    end

    it "assigns the requested project as @project" do
      expect(assigns(:project)).to eq(project)
    end

    it "renders the show.json template" do
      expect(response).to render_template('show.json')
    end

    it "is successful" do
      expect(response.status).to eq(200)
    end
  end
  # ====================================================================================================================
  describe "POST create" do
    describe "with valid params" do
      it "creates a new Project" do
        expect {
          post :create, {:project => valid_attributes}, valid_session
        }.to change(user.projects, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        post :create, {:project => valid_attributes}, valid_session
        expect(assigns(:project)).to be_a(Project)
        expect(assigns(:project)).to be_persisted
      end

      it "renders the show.json template" do
        post :create, {:project => valid_attributes}, valid_session
        expect(response).to render_template('show.json')
      end

      it "is successful" do
        post :create, {:project => valid_attributes}, valid_session
        expect(response.status).to eq(200)
      end
    end

    describe "with invalid params" do
      it "fails to create a new Project" do
        expect {
          post :create, {:project => invalid_attributes}, valid_session
        }.to change(user.projects, :count).by(0)
      end

      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        # Project.any_instance.stub(:save).and_return(false)
        post :create, {:project => invalid_attributes}, valid_session
        assigns(:project).should be_a_new(Project)
      end

      it "renders errors" do
        # Trigger the behavior that occurs when invalid params are submitted
        # project = Project.any_instance.stub(:errors).and_return(false)
        post :create, {:project => invalid_attributes}, valid_session
        # TODO: find out how to expect render project.errors
        expect(response.body).to have_content 'is too short'
      end

      it "responds with 422" do
        project = Project.any_instance.stub(:save).and_return(false)
        post :create, {:project => invalid_attributes}, valid_session
        expect(response.status).to eq(422)
      end
    end
  end
  # ====================================================================================================================
  describe "PUT update" do
    let(:project) { user.projects.create! valid_attributes }

    describe "with valid params" do
      it "updates the requested project" do
        # Assuming there are no other projects in the database, this
        # specifies that the Project created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Project.any_instance.should_receive(:update).with(valid_attributes).and_return(true)
        put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
      end

      it "assigns the requested project as @project" do
        put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
        assigns(:project).should eq(project)
      end

      it "renders show.json" do
        put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
        expect(response).to render_template('show.json')
      end

      it "is successful" do
        put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
        expect(response.status).to eq(200)
      end
    end

    describe "with invalid params" do
      it "fails to update a project" do
        Project.any_instance.should_receive(:update).with(invalid_attributes).and_return(false)
        put :update, {:id => project.to_param, :project => invalid_attributes}, valid_session
      end

      it "assigns the project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        # Project.any_instance.stub(:save).and_return(false)
        put :update, {:id => project.to_param, :project => invalid_attributes}, valid_session
        assigns(:project).should eq(project)
      end

      it "renders errors" do
        # Trigger the behavior that occurs when invalid params are submitted
        # project = Project.any_instance.stub(:errors).and_return(false)
        put :update, {:id => project.to_param, :project => invalid_attributes}, valid_session
        # TODO: find out how to expect render project.errors
        # TODO: maybe 'to have key' or 'errors to_not be empty'
        expect(response.body).to have_content 'is too short'
      end

      it "responds with 422" do
        # project = Project.any_instance.stub(:save).and_return(false)
        put :update, {:id => project.to_param, :project => invalid_attributes}, valid_session
        expect(response.status).to eq(422)
      end
    end
  end
  # ====================================================================================================================
  describe "DELETE destroy" do
    let(:project) { user.projects.create! valid_attributes }

    it "renders nothing" do
      expect(response.body).to be_empty
    end

    # TODO: "with successful destroy" ?
    describe "with successful destroy" do
      # TODO: this doesnt work for some reason
      it "destroys the requested project" do
        project = user.projects.create! valid_attributes
        Project.any_instance.should_receive(:destroy).and_call_original

        expect {
          delete :destroy, {:id => project.to_param}, valid_session
        }.to change(user.projects, :count).by(-1)
      end

      it "assigns destroyed project as @project" do
        delete :destroy, {:id => project.to_param}, valid_session
        expect(assigns(:project)).to eq(project)
        expect(assigns(:project)).to be_destroyed
      end

      it "responds with 204" do
        delete :destroy, {:id => project.to_param}, valid_session
        expect(response.status).to eq(204)
      end
    end
    # TODO: "with failed destroy" ?
    describe "with failed destroy" do
      before :each do
        Project.any_instance.stub(:destroy).and_return(false)
      end
      it "fails to destroy project" do
        # TODO: return value doesn't work at all
        Project.any_instance.should_receive(:destroy).and_return(false)
        project = user.projects.create! valid_attributes
        expect {
          delete :destroy, {:id => project.to_param}, valid_session
        }.to change(user.projects, :count).by(0)
      end

      it "assigns not destroyed project as @project" do
        delete :destroy, {:id => project.to_param}, valid_session
        expect(assigns(:project)).to eq(project)
        expect(assigns(:project)).to_not be_destroyed
      end

      it "responds with 422" do
        delete :destroy, {:id => project.to_param}, valid_session
        expect(response.status).to eq(422)
      end
    end
  end
end