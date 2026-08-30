# frozen_string_literal: true

agreement_versions = [
  {
    agreement_key: "user_terms",
    version: "2026-08-30",
    acceptance_statement: "I accept the Moneygun Terms of Service and acknowledge the Privacy Notice.",
    documents: [
      { title: "Terms of Service", url: "https://example.com/terms" },
      { title: "Privacy Notice", url: "https://example.com/privacy" }
    ]
  },
  {
    agreement_key: "organization_dpa",
    version: "2026-08-30",
    acceptance_statement: "I accept the Moneygun Data Processing Agreement on behalf of this organization.",
    documents: [{ title: "Data Processing Agreement", url: "https://example.com/dpa" }]
  }
]

agreement_versions.each do |attributes|
  version = Agreements::Version.find_or_initialize_by(attributes.slice(:agreement_key, :version))
  if version.new_record?
    version.assign_attributes(attributes)
    version.save!
  end

  matches = version.acceptance_statement == attributes.fetch(:acceptance_statement) && version.documents == attributes.fetch(:documents).as_json
  raise "Agreement #{version.agreement_key} #{version.version} differs from its deployed evidence" unless matches
end
