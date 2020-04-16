class RegulationFinish < ActiveRecord::Base

  belongs_to :position
  belongs_to :regulation

  def name
    [finish_name, opacity_name, luminous_name].compact.join(' ')
  end

  def finish_name
    Decal::FINISHES[finish_id]
  end

  def opacity_name
    Decal::OPACITIES[opacity_id]
  end

  def luminous_name
    luminous? ? 'Luminous' : nil
  end

end
