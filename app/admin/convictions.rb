ActiveAdmin.register Conviction do
  permit_params :politician_id, :conviction_date, :offense_type, :sentence_prison,
                :sentence_fine, :sentence_ineligibility, :appeal_status, :description,
                :source_url, :verified

  index do
    selectable_column
    id_column
    column :politician
    column :conviction_date
    column :offense_type
    column :appeal_status
    column :verified
    column :created_at
    actions
  end

  filter :politician
  filter :conviction_date
  filter :offense_type
  filter :appeal_status
  filter :verified
  filter :created_at

  form do |f|
    f.inputs do
      f.input :politician, as: :select, collection: Politician.all.map { |p| [p.name, p.id] }
      f.input :conviction_date, as: :datepicker
      f.input :offense_type
      f.input :sentence_prison
      f.input :sentence_fine
      f.input :sentence_ineligibility
      f.input :appeal_status, as: :select, collection: Conviction.appeal_statuses.keys
      f.input :description
      f.input :source_url
      f.input :verified
    end
    f.actions
  end

  show do
    attributes_table do
      row :politician
      row :conviction_date
      row :offense_type
      row :sentence_prison
      row :sentence_fine
      row :sentence_ineligibility
      row :appeal_status
      row :description
      row :source_url do |c|
        link_to 'Source', c.source_url, target: '_blank'
      end
      row :verified
      row :created_at
      row :updated_at
    end
  end
end
