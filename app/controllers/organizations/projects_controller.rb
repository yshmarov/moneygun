# frozen_string_literal: true

class Organizations::ProjectsController < Organizations::BaseController
  before_action :set_project, only: %i[show edit update destroy]

  # GET /organizations/1/projects
  def index
    authorize Project
    @projects = @organization.projects
  end

  # GET /organizations/1/projects/1
  def show; end

  # GET /organizations/1/projects/new
  def new
    @project = @organization.projects.new
    authorize @project
  end

  # GET /organizations/1/projects/1/edit
  def edit; end

  # POST /organizations/1/projects
  def create
    @project = @organization.projects.new(project_params.merge(membership: Current.membership))
    authorize @project

    if @project.save
      log_project_event("project.created", subject: @project)
      respond_to do |format|
        flash[:notice] = t(".success")
        format.html { redirect_to organization_project_url(@organization, @project) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_project_url(@organization, @project)) }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /organizations/1/projects/1
  def update
    if @project.update(project_params)
      log_project_event("project.updated", subject: @project, changes: @project.previous_changes.except("updated_at"))
      respond_to do |format|
        flash[:notice] = t(".success")
        format.html { redirect_to organization_project_url(@organization, @project) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_project_url(@organization, @project)) }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /organizations/1/projects/1
  def destroy
    metadata = { project_id: @project.id, project_name: @project.name }
    @project.destroy!
    log_project_event("project.deleted", **metadata)

    redirect_to organization_projects_url(@organization), notice: t(".success")
  end

  private

  def set_project
    @project = @organization.projects.find(params[:id])
    authorize @project
  end

  def project_params
    params.expect(project: [:name, :description, :status, :priority, :start_date, :due_date,
                            :scheduled_at, :budget, :is_active, :category, :document, :body,
                            :contact_email, :website_url, :phone_number, :start_time,
                            :completion_percentage, :color, :search_keywords, :secret_token,
                            :price, :cost, :cover_image,
                            { tags: [], attachments: [], gallery: [] }])
  end

  def log_project_event(action, subject: nil, **metadata)
    AuditLog.log!(organization: @organization, actor: Current.membership, subject: subject,
                  action: action, actor_kind: Current.audit_actor_kind, mini_app: "projects", metadata: metadata)
  end
end
