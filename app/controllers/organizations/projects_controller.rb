class Organizations::ProjectsController < Organizations::BaseController
  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :require_subscription, only: %i[ new create ]

  # GET /organizations/1/projects
  def index
    authorize Project
    @projects = @organization.projects
  end

  # GET /organizations/1/projects/1
  def show
  end

  # GET /organizations/1/projects/new
  def new
    @project = @organization.projects.new
    authorize @project
  end

  # GET /organizations/1/projects/1/edit
  def edit
  end

  # POST /organizations/1/projects
  def create
    @project = @organization.projects.new(project_params)
    authorize @project

    if @project.save
      redirect_to organization_project_url(@organization, @project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/1/projects/1
  def update
    if @project.update(project_params)
      redirect_to organization_project_url(@organization, @project), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/1/projects/1
  def destroy
    @project.destroy!

    redirect_to organization_projects_url(@organization), notice: "Project was successfully destroyed."
  end

  private
    def set_project
      @project = @organization.projects.find(params[:id])
      authorize @project
    end

    def project_params
      params.require(:project).permit(:name)
    end

  def require_subscription
    return true if @organization.projects.count < 1
    return true if @organization.payment_processor.subscribed?

    redirect_to organization_subscriptions_path(@organization), alert: "You need to have an active subscription to create more than 1 project."
  end
end
