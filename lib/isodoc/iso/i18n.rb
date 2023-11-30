module IsoDoc
  module Iso
    class I18n < IsoDoc::I18n
      def load_file(fname)
        f = File.join(File.dirname(__FILE__), fname)
        File.exist?(f) ? YAML.load_file(f) : {}
      end

      alias :local_load_file :load_file

      def load_yaml1(lang, script)
        y = local_load_file("i18n-#{yaml_lang(lang, script)}.yaml")
        y.empty? and return local_load_file("i18n-en.yaml").deep_merge(super)
        super.deep_merge(y)
      end
    end
  end
end
