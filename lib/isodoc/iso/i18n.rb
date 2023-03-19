module IsoDoc
  module Iso
    class I18n < IsoDoc::I18n
      def load_file(fname)
        YAML.load_file(File.join(File.dirname(__FILE__), fname))
      end

      # all gems inheriting from ISO need to be represented here,
      # even if the file is empty
      # e.g. JA for metanorma-jis
      def load_yaml1(lang, script)
        y = if lang == "en" then load_file("i18n-en.yaml")
            elsif lang == "fr" then load_file("i18n-fr.yaml")
            elsif lang == "ru" then load_file("i18n-ru.yaml")
            elsif lang == "ja" then load_file("i18n-ja.yaml")
            elsif lang == "zh" && script == "Hans"
              load_file("i18n-zh-Hans.yaml")
            else load_file("i18n-en.yaml")
            end
        super.deep_merge(y)
      end
    end
  end
end
