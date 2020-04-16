class ThemePreview < ActiveRecord::Base
  belongs_to :theme

  def path
    "/data/themes/#{filename}"
  end

  def filename
    "#{theme.external_id}_#{slugified_name}.png"
  end

  def slugified_name
    name.gsub(' ', '_')
        .downcase
  end
end
