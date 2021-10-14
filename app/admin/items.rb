ActiveAdmin.register Item do
  menu label: "#{I18n.t('activerecord.models.item')} 관리"

  controller do
    def scoped_collection
      Item.includes(:received_likes)
    end
  end

  scope -> { "전체" }, :all

  filter :title_cont, label: "#{I18n.t('activerecord.attributes.item.title')} 필터"
  filter :price_eq, label: "#{I18n.t('activerecord.attributes.item.price')} 필터"
  filter :category, label: "#{I18n.t('activerecord.attributes.item.category')} 필터"
  # filter :provider, label: "#{I18n.t('activerecord.attributes.item.user')} 필터"
  filter :status_eq, label: "#{I18n.t('activerecord.attributes.item.status')} 필터"

  index do
    selectable_column
    id_column
    tag_column :status, interactive: true
    column :image do |item| image_tag(item.image_path, class: "admin-index-image") end
    column :category
    column :user
    column :title
    column :price do |item| number_to_currency(item.price, unit: "원") end
    column :created_at
    column :updated_at
    column "좋아요 수" do |item| number_to_currency(item.received_likes.size, unit: "개") end
    actions do |item|
      link_to "옵션관리", admin_item_options_path(item), class: "member_link"
    end
  end

  show do
    attributes_table do
      row :id
      row :status do |item| number_to_currency(item.status, unit: "") end
      row :image do |item| image_tag(item.image_path, class: "admin-show-image") end
      row :category
      row :title
      row :price do |item| number_to_currency(item.price, unit: "원") end
      row :description
      row :user
      row :created_at
      row :updated_at
      row "댓글 개수" do |item| number_to_currency(item.received_comments.size, unit: "개") end
      row "좋아요 수" do |item| number_to_currency(item.received_likes.size, unit: "개") end
      panel "이미지 리스트" do
        table_for "이미지" do
          item.images.each_with_index do |image, index|
            column "이미지#{index}" do
              image_tag(image.image_path, class: "admin-show-image", style: "width: 300px")
            end
          end
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :price
      f.input :category
      f.input :description
      f.input :user
      f.input :image
      f.input :status, collection: Item.enum_selectors(:status)

      f.has_many :images do |p|
        p.inputs "사진업로드" do
          p.input :image
        end
      end
    end
    f.actions
  end
end
