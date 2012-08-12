# _bootstrap gets things going

# namespace function lets you place other functions in namespaces
# during the rest of the execution context
window.namespace = (target, name, block) =>
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

