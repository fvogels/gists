class OverviewBlock < Asciidoctor::Extensions::BlockProcessor
  use_dsl
  named :overview
  on_context :listing   # Should not be important
  parse_content_as :raw # Should not be important

  def process(parent, reader, attrs)
    # Important: no newlines must be included, otherwise parse_content will fail
    lines = <<~END.lines.map(&:rstrip)
    |===
    | a | b
    |===
    END

    create_open_block(parent, [], attrs).tap do |parent_block|
      parse_content(parent_block, lines, {})
    end
  end
end