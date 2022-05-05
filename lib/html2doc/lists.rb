class Html2Doc
  class IsoDIS < ::Html2Doc
    def list2para(list)
      return if list.xpath("./li").empty?

      list.xpath("./li").each do |l|
        l.name = "p"
        if m = /level(\d) lfo/.match(l["style"])
          l["class"] = list2para_style(list.name, m[1])
          l.xpath("./p").each do |p|
            p["class"] = list2para_style(list.name, m[1])
          end
        end
        l&.first_element_child&.name == "p" and
          l.first_element_child.replace(l.first_element_child.children)
      end
      list.replace(list.children)
    end

    def list2para_style(listtype, depth)
      case listtype
      when "ul"
        case depth
        when "1" then "ListContinue1"
        when "2", "3", "4" then "MsoListContinue#{depth}"
        else "MsoListContinue5"
        end
      when "ol"
        case depth
        when "1" then "ListNumber1"
        when "2", "3", "4" then "MsoListNumber#{depth}"
        else "MsoListNumber5"
        end
      end
    end
  end
end