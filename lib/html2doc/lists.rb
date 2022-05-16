class Html2Doc
  class IsoDIS < ::Html2Doc
    def list2para(list)
      return if list.xpath("./li").empty?

      list.xpath("./li").each do |l|
        level = l["level"]
        l.delete("level")
        l.name = "p"
        if level
          l["class"] = list2para_style(list.name, level)
          l.xpath("./p").each do |p|
            p["class"] = list2para_style(list.name, level)
          end
        end
        p = l.at("./p") and p.replace(p.children)
        p = l.at("./ul | ./ol") and l.replace(p)
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
      docxml.xpath("//div[@class = 'Note' or @class = 'Example' or "\
                   "@class = 'Quote']").each do |d|
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

    def list_add(xpath, liststyles, listtype, level)
      xpath.each do |l|
        l["seen"] = true if level == 1
        l["id"] ||= UUIDTools::UUID.random_create
        i = 0
        (l.xpath(".//li") - l.xpath(".//ol//li | .//ul//li")).each do |li|
          i = style_list_iso(li, level, listtype, i)
          list_add1(li, liststyles, listtype, level)
        end
        list_add_tail(l, liststyles, listtype, level)
      end
    end

    def list_add_tail(list, liststyles, listtype, level)
      list.xpath(".//ul[not(ancestor::li/ancestor::*/@id = '#{list['id']}')] | "\
                 ".//ol[not(ancestor::li/ancestor::*/@id = '#{list['id']}')]")
        .each do |li|
        list_add1(li.parent, liststyles, listtype, level - 1)
      end
    end

    def style_list_iso(elem, level, listtype, idx)
      return idx if elem.at(".//ol | .//ul")

      idx += 1
      label = listlabel(listtype, idx, level)
      elem.children.first.previous =
        "#{label}<span style='mso-tab-count:1'>&#xa0;</span>"
      elem["level"] = level
      idx
    end

    def listlabel(listtype, idx, level)
      case listtype
      when :ul then "&#x2014;"
      when :ol then "#{listidx(idx, level)})"
      end
    end

    def listidx(idx, level)
      case level
      when 1, 6 then (96 + idx).chr.to_s
      when 2, 7 then idx.to_s
      when 3, 8 then RomanNumerals.to_roman(idx).downcase
      when 4, 9 then (64 + idx).chr.to_s
      when 5, 10 then RomanNumerals.to_roman(idx).upcase
      end
    end

    def cleanup(docxml)
      super
      docxml.xpath("//div[@class = 'Quote' or @class = 'Example' or "\
                   "@class = 'Note']").each do |d|
        d.delete("class")
      end
      docxml
    end
  end
end
