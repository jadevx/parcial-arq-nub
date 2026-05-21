function CodeBlock(block)
  if block.classes[1] == "mermaid" then
    return pandoc.RawBlock("html", '<div class="mermaid">\n' .. block.text .. '\n</div>')
  end
end
