
primitives = ['string','number','boolean']
isPrimitive = (value) -> -1 isnt primitives.indexOf typeof value

isArray = (object) -> Object.prototype.toString.call(object) is '[object Array]'

pattern = ///
  ^
  (
    ([^\.]+?)
    (\[([0-9]+)\])?
    ($|\.)
  )
///

parse = (path) ->
  match = path.match pattern
  if not match
    throw new Error "unparseable path: #{path}"
  key = match[2]
  index = parseInt match[4], 10 if match[4]
  result = [{
    key : key
    index : index
  }]
  if match[1].length is path.length and match[1].slice(-1) isnt '.'
    return result
  else
    return result.concat parse path.substring match[1].length

get = (path, object) ->
  query = parse path
  for obj in query
    object = object[obj.key]
    return null if object is null
    if not isNaN obj.index
      object = object[obj.index]
    return null if object is null
  return object

set = (path, object, value) ->
  initial = object
  query = parse path
  parent = null
  for obj in query
    hasIndex = not isNaN obj.index
    parent = object
    object = object[obj.key] or= if hasIndex then [] else {}
    if hasIndex
      parent = object
      object = object[obj.index] or= {}
  obj = query.slice(-1)[0]
  if not isNaN obj.index
    parent[obj.index] = value
  else
    parent[obj.key] = value
  return initial

flatten = (object, prefix, target = {}) ->
  if isArray object
    for value, index in object
      property = prefix + '[' + index + ']'
      if isPrimitive value
        target[property] = value
      else
        target = flatten value, property, target
  else
    for key, value of object
      property = if prefix then "#{prefix}.#{key}" else key
      if isPrimitive value
        target[property] = value
      else
        flatten value, property, target
  return target

unflatten = (object, prefix, target = {}) ->
  for key, value of object
    set key, target, value
  return target

merge = (object, object2) ->
  result = {}
  for key, value of (flatten object)
    result[key] = value
  for key, value of (flatten object2)
    result[key] = value
  unflatten result

API =
  get : get
  set : set
  flatten : flatten
  unflatten : unflatten
  merge : merge

target = if exports? then exports else if window? then window.Flattener={} else null

for k,v of API
  target[k] = v


