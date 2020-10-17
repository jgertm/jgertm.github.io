function Link(el)
  el.target = string.gsub(el.target, "%.org", ".html")
  return el
end
