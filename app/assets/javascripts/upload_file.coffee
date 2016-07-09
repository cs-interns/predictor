Upload = () ->
  # private
  id = 0 
  id_len = 6

  # public
  get_id = () ->
    id = id || Array(id_len + 1).join((Math.random().toString(36)+'00000000000000000').slice(2, 18)).slice(0, id_len)
    id
