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

    def lists(docxml, liststyles)
      super
      indent_lists(docxml)
    end

    def indent_lists(docxml)
      docxml.xpath("//div[@class = 'Note' or @class = 'Example']").each do |d|
        d.xpath(".//p").each do |p|
          indent_lists1(p)
        end
      end
    end

    def indent_lists1(para)
      m = /^(ListContinue|ListNumber|MsoListContinue)(\d)$/
        .match(para["class"]) or return
      base = m[1]
      base = "Mso#{base}" unless /^Mso/.match?(base)
      para["class"] = base + (m[2].to_i + 1).to_s
    end
  end
end
