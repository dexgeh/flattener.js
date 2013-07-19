test = (fn, args, expect) ->
  result = null
  try
    result = fn.apply {}, args
  catch e
    result = e
  if expect and (JSON.stringify result) isnt (JSON.stringify expect)
    console.log result.stack if result.stack
    throw new Error "expect: #{JSON.stringify expect} got: #{JSON.stringify result}"

f = if Flattener? then Flattener else require './flattener'

run_test = () ->
  test_get = (path, object, expect) -> test f.get, [path, object], expect
  test_set = (path, object, value, expect) -> test f.set, [path,object, value], expect
  test_flatten = (object, expect) -> test f.flatten, [object], expect
  test_unflatten = (object, expect) -> test f.unflatten, [object], expect
  test_flatten_unflatten = (object) ->
    if (JSON.stringify f.unflatten f.flatten object) is (JSON.stringify object)
      return yes
    else
      throw new Error "unmatched flatten-unflatten for input #{JSON.stringify object}"
  test_get 'a.', {}, no
  test_get '[1]', {}, no
  test_get 'a', {a:1}, 1
  test_get 'a.b', {a:{b:1}}, 1
  test_get 'a[0].b', {a:[{b:1}]}, 1
  test_get 'a[0].b[1]', {a:[{b:[1,2]}]}, 2
  test_set 'a', {}, 1, {a:1}
  test_set 'a.b', {}, 1, {a:{b:1}}
  test_set 'a[0].b', {}, 1, {a:[{b:1}]}
  test_set 'a[0].b[0]', {}, 1, {a:[{b:[1]}]}
  test_set 'a.b[0].c.d', {}, 1, {a:{b:[{c:{d:1}}]}}
  test_flatten {a:1}, {a:1}
  test_flatten {a:{b:1}}, {'a.b':1}
  test_flatten {a:{b:[1,2]}}, {'a.b[0]':1, 'a.b[1]':2}
  test_flatten {'[':1}, {'[':1}
  test_flatten {'a[b':{'c]d':1}}, {'a[b.c]d':1}
  test_unflatten {a:1}, {a:1}
  test_unflatten {'a.b':1}, {a:{b:1}}
  test_unflatten {'a.b[0].c':1}, {a:{b:[{c:1}]}}
  test_flatten_unflatten {a:{b:[1,2]}}
  console.log "OK"

run_test()
