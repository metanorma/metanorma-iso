Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

#gem "asciimath", git: "https://github.com/asciidoctor/asciimath"
gem 'isodoc',
    git: 'https://github.com/metanorma/isodoc.git',
    branch: 'feature/sassc-gem-dependecey-removal',
    ref: '963c80b0c0c4f223fb461d159fea5a9a2e46be3f'
gemspec

if File.exist? 'Gemfile.devel'
  eval File.read('Gemfile.devel'), nil, 'Gemfile.devel' # rubocop:disable Security/Eval
end

