# frozen_string_literal: true

class Organizations::DataExportsController < Organizations::BaseController
  rate_limit to: 5, within: 1.hour, only: :create, by: -> { @organization.id },
             with: -> { redirect_to organization_data_exports_path(@organization), alert: t("shared.errors.rate_limit") }

  def index
    authorize DataExport
    @data_export = @organization.data_exports.recent.includes(membership: :user).first
  end

  def show
    data_export = @organization.data_exports.find(params.expect(:id))
    authorize data_export
    return redirect_to organization_data_exports_path(@organization), alert: t(".unavailable") unless data_export.downloadable?
    return if require_sudo(:export_data)

    data_export.log_downloaded!(by: Current.membership)
    redirect_to rails_blob_path(data_export.file, disposition: "attachment")
  end

  def create
    authorize DataExport
    data_export = @organization.data_exports.create!(membership: Current.membership)
    DataExport::GenerateJob.perform_later(data_export)
    redirect_to organization_data_exports_path(@organization)
  end
end
