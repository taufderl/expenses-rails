module ExpensesHelper
  
  def source_image source
    case source
    when 'ing'
      return image_tag 'ING.png', size: "16x16"
    when 'dkb_giro'
      return image_tag 'dkb.png', size: "16x16"
    when 'dkb_credit'
      return image_tag 'visa2.jpg', size: "16x10"
    when 'sparkasse'
      return image_tag 'sparkasse.png', size: "16x16"
    when 'excel'
      return image_tag 'Excel.png', size: "16x16"
    when 'webapp'
      return image_tag 'favicon.png', size: "16x16"
    when 'android'
      return image_tag 'android.png', size: "16x16"
    else
      return ""
    end
  end
end
