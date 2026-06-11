# 07: Math & Image Handling

## Summary

Implement MathML/OMML and image handling in the XML→DOCX adapter, ensuring math equations render correctly and images embed at proper dimensions.

## Motivation

ISO documents heavily use both mathematical notation (via MathML) and embedded images (figures, diagrams). These require special handling beyond simple text conversion.

## Prerequisites

- 03: XML-to-DOCX Adapter
- Uniword >= 1.0.6 (ImageBuilder)

## Tasks

### 1. Math handling

#### Current pipeline (html2doc)
1. isodoc produces `<stem type="MathML">` elements in HTML
2. html2doc converts MathML → OMML via Plurimath
3. html2doc post-processes OMML: unitalic variables, accents, plane1 fonts, centering

#### New pipeline (direct)
1. isodoc produces `<stem>` elements in presentation XML
2. DocxAdapter calls Plurimath to convert MathML → OMML
3. Apply the same post-processing (unitalic, accents, plane1 fonts, centering)
4. Embed OMML as `<m:oMath>` / `<m:oMathPara>` in the paragraph

Implementation:
```ruby
def visit_stem(element, para)
  mathml = element.at("m:math") || element.inner_html
  omml = Plurimath::Math.parse(mathml, "mathml").to_ooml
  omml_doc = Nokogiri::XML(omml)
  # Post-process: unitalic variables, accents, plane1 fonts
  post_process_math(omml_doc)
  # Wrap in Uniword run with OMML content
  para << omml_run(omml_doc)
end
```

The post-processing logic from `html2doc/math.rb` should be extracted into a shared module (in isodoc or a separate gem) to avoid duplication.

#### Alternative: Let Uniword handle it
If Uniword gains MathML→OMML conversion, the adapter can delegate:
```ruby
doc.math(mathml_string, format: :mathml)
```

### 2. Image handling

#### Current pipeline (html2doc)
1. HTML `<img>` tags reference local files
2. html2doc renames to UUIDs, detects MIME type (marcel)
3. Resizes via vectory based on page dimensions
4. Embeds in DOCX via `ImageBuilder.create_run`

#### New pipeline (direct)
1. Presentation XML `<image>` elements reference files
2. DocxAdapter reads the file, detects MIME type
3. Resizes to fit page dimensions (use same vectory logic)
4. Embeds via `DocumentBuilder#image`:
   ```ruby
   doc.image(path, width: emu_width, height: emu_height, alt_text: alt)
   ```

Implementation:
```ruby
def visit_image(element, builder)
  path = element["src"]
  # Resolve path relative to document directory
  # Detect dimensions and resize
  width, height = calculate_image_dimensions(path)
  builder.image(path, width: width, height: height, alt_text: element["alt"])
end
```

### 3. Floating images

ISO documents use inline images in most cases, but some figures need floating positioning:
```ruby
builder.floating_image(path,
  width: width, height: height,
  align: :center,
  wrap: :top_and_bottom
)
```

### 4. Image part management

Ensure images are packaged into `word/media/` with proper content types:
- `_rels/.rels` relationships for images
- `[Content_Types].xml` entries for image MIME types
- Unique filenames (UUID-based)

Uniword's `ImageBuilder` handles this automatically.

### 5. SVG images

SVG is not natively supported in DOCX. Options:
- Convert SVG → PNG (via mini_magick or similar) before embedding
- Use EMF format (Windows only)
- Rasterize at a minimum DPI

html2doc currently does not support SVG. This limitation should be documented.

## Acceptance Criteria

- [ ] MathML equations convert to valid OMML
- [ ] Post-processing (unitalic, accents, plane1 fonts) applied
- [ ] Images embed at correct dimensions
- [ ] Image MIME types detected correctly
- [ ] Images packaged in `word/media/` with proper content types
- [ ] Floating images supported for figures
- [ ] SVG limitation documented

## Open Questions

- Should math post-processing stay in html2doc/math.rb, or move to isodoc?
- What's the minimum required image format support? (PNG, JPEG, TIFF, EMF, WMF)
- Should we use vectory for dimension calculation or Uniword's built-in handling?
