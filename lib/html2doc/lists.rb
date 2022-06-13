class Html2Doc
  class IsoDIS < ::Html2Doc
    def list2para(list)
      return if list.xpath("./li").empty?

      list.xpath("./li").each do |l|
        list2para_level(l, list)
      end
    end

    def list2para_level(item, list)
      level = item["level"]
      item.delete("level")
      item.name = "p"
      list2para_nest(item, level, list) if level
    end

    def list2para_nest(item, level, list)
      item["class"] = list2para_style(list.name, level)
      item.xpath("./p").each do |p|
        p["class"] = list2para_style(list.name, level)
      end
      p1 = item.at("./p") or return
      prev = p1.xpath("./preceding-sibling::* | ./preceding-sibling::text()")
      if prev[-1].name == "span" && prev[-1]["style"] == "mso-tab-count:1" &&
          prev.size == 2
        p1.children.first.previous = prev[1]
        p1.children.first.previous = prev[0]
      end
    end

    def list2para_unnest_para(para, first_p, last_p)
      return if last_p.xpath("./following-sibling::* | ./following-sibling::text()")
        .any? do |x|
                  !x.text.strip.empty?
                end

      prev = first_p.xpath("./preceding-sibling::* | "\
                           "./preceding-sibling::text()[normalize-space()]")
      # bullet, tab, paragraph: ignore bullet, tab
      if prev.empty? then para.replace(para.children)
      elsif prev.size == 2 && prev[-1].name == "span" &&
          prev[-1]["style"] == "mso-tab-count:1"
        first_p.replace(first_p.children)
      end
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
      docxml.xpath("//p[ol | ul]").each do |p|
        list2para_unnest_para(p, p.at("./ol | ./ul"),
                              p.at("./*[name() = 'ul' or name() = 'ol'][last()]"))
      end
      docxml.xpath("//ol | //ul").each do |u|
        u.replace(u.children)
      end
      unnest_list_paras(docxml)
      indent_lists(docxml)
    end

    def unnest_list_paras(docxml)
      docxml.xpath("//p[@class = 'ListContinue1' or @class = 'ListNumber1']"\
                   "[.//p]").each do |p|
                     p.at("./p") and
                       list2para_unnest_para(p, p.at("./p"),
                                             p.at("./p[last()]"))
                     p.xpath(".//p[p]").each do |p1|
                       list2para_unnest_para(p1, p1.at("./p"),
                                             p1.at("./p[last()]"))
                     end
                   end
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
      m = /^(ListContinue|ListNumber|MsoListContinue|MsoListNumber)(\d)$/
        .match(para["class"]) or return
      base = m[1].sub(/^Mso/, "")
      level = m[2].to_i + 1
      level = 5 if level > 5
      para["class"] = "#{base}#{level}-"
    end

    def list_add(xpath, liststyles, listtype, level)
      xpath.each do |l|
        l["seen"] = true if level == 1
        l["id"] ||= UUIDTools::UUID.random_create
        list_add_number(l, liststyles, listtype, level)
        list_add_tail(l, liststyles, listtype, level)
      end
    end

    def list_add_number(list, liststyles, listtype, level)
      i = list["start"] ? list["start"].to_i - 1 : 0
      (list.xpath(".//li") - list.xpath(".//ol//li | .//ul//li")).each do |li|
        i = style_list_iso(li, level, listtype, i)
        list_add1(li, liststyles, listtype, level)
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
      return idx if elem.at(".//ol | .//ul") && !elem.at("./p")

      idx += 1
      ol = elem.xpath("./ancestor::ol")&.last
      label = listlabel(listtype, idx, ol ? ol["type"] : nil)
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
      when "a" then (96 + idx).chr.to_s
      when "1" then idx.to_s
      when "i" then RomanNumerals.to_roman(idx).downcase
      when "A" then (64 + idx).chr.to_s
      when "I" then RomanNumerals.to_roman(idx).upcase
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
