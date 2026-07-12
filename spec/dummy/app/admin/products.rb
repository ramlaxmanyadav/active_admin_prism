ActiveAdmin.register Product do
  menu label: "Products", parent: "E-Commerce", priority: 1, html_options: { icon: :box }

  permit_params :name, :price, :active

  index do
    selectable_column
    id_column
    column :name
    column :price
    column :active do |product|
      prism_toggle_tag product.active
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :price
      row :active do |product|
        prism_toggle_tag product.active
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :price
      f.input :active, as: :prism_toggle
    end
    f.actions
  end
end
