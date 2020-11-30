# Inside processor class
def create_link(parent, text, url)
  create_anchor(parent, text, { type: :xref }).tap do |link|
    link.target = url
  end
end