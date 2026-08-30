# frozen_string_literal: true

require "zip"

class DataExport::GenerateJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound

  def perform(data_export)
    return if data_export.completed?

    Tempfile.create(["data_export", ".zip"]) do |tempfile|
      tempfile.binmode
      build_zip(tempfile.path, data_export.organization)
      tempfile.rewind
      data_export.complete!(tempfile)
    end
  rescue StandardError
    data_export.failed! if data_export.persisted?
    raise
  end

  private

  def build_zip(path, organization)
    Zip::OutputStream.open(path) do |zip|
      write_json(zip, "organization.json", organization.attributes)
      write_json(zip, "memberships.json", memberships_data(organization))
      write_json(zip, "projects.json", projects_data(organization))
      write_project_files(zip, organization)
    end
  end

  def write_json(zip, name, data)
    zip.put_next_entry(name)
    zip.write(JSON.pretty_generate(data))
  end

  def memberships_data(organization)
    organization.memberships.includes(:user).map do |membership|
      membership.attributes.merge("email" => membership.user.display_email, "name" => membership.display_name)
    end
  end

  def projects_data(organization)
    organization.projects.with_rich_text_body.map do |project|
      project.attributes.merge("body" => project.body.to_s)
    end
  end

  def write_project_files(zip, organization)
    organization.projects.with_attached_document.with_attached_attachments.with_attached_cover_image.with_attached_gallery.find_each do |project|
      attachments = [project.document.attachment, project.cover_image.attachment].compact + project.attachments.attachments + project.gallery.attachments
      attachments.each do |attachment|
        zip.put_next_entry("projects/#{project.id}/files/#{attachment.id}-#{attachment.filename.sanitized}")
        attachment.blob.download { |chunk| zip.write(chunk) }
      end
    end
  end
end
