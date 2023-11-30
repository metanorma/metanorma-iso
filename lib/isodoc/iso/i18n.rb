module IsoDoc
  module Iso
    class I18n < IsoDoc::I18n
      # name iso_load_file instead of load_file
      # so that child flavours cannot inherit it and override it
      def iso_load_file(fname)
        f = File.join(File.dirname(__FILE__), fname)
        File.exist?(f) ? YAML.load_file(f) : {}
      end

      def load_yaml1(lang, script)
        y = iso_load_file("i18n-#{yaml_lang(lang, script)}.yaml")
        y.empty? and return iso_load_file("i18n-en.yaml").deep_merge(super)
        super.deep_merge(y)
      end
    end
  end
end
