ActiveAdmin.register Politician do
  permit_params :name, :party, :photo_url, :position, :wikipedia_url, :active, :hemicycle_position

  index do
    selectable_column
    id_column
    column :name
    column :party
    column :position
    column :active
    column :created_at
    actions
  end

  filter :name
  filter :party
  filter :position
  filter :active
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :party
      f.input :photo_url
      f.input :position, as: :select, collection: Politician.positions.keys
      f.input :wikipedia_url
      f.input :active
      f.input :hemicycle_position, as: :text, placeholder: '{"x": 0.5, "y": 0.5}'
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :party
      row :photo_url do |p|
        image_tag p.photo_url, size: '100x100' if p.photo_url.present?
      end
      row :position
      row :wikipedia_url do |p|
        link_to 'Wikipedia', p.wikipedia_url, target: '_blank' if p.wikipedia_url.present?
      end
      row :active
      row :hemicycle_position
      row :created_at
      row :updated_at
    end

    panel 'Convictions' do
      table_for politician.convictions do
        column :conviction_date
        column :offense_type
        column :appeal_status
        column :verified
        column 'Actions' do |conviction|
          link_to 'View', admin_conviction_path(conviction)
        end
      end
    end
  end
end
