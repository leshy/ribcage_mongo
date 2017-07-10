require! {
  colors  
  assert
  mongodb: { ObjectId }
  leshdash: { each, last, head, rpad, lazy, union, assign, omit, map, curry, times, keys, first, wait, head, pwait, wait, mapValues, reverse, reduce, filter }
  bluebird: p
  ribcage: { init }
  backbone4000: Backbone
}

before -> new p (resolve,reject) ~>
  env = do
    settings:
      module:
        mongo:
          name: 'test'

  init env, (err,env) ~>
    @Model =  Backbone.Model.extend4000 inspect: -> "MODEL #{@id}"
    @Collection = Backbone.Collection.extend4000 do
      name: 'testCollection'
      inspect: -> "COLLECTION #{@length}"

    @Collection::sync = @Model::sync = env.mongo.sync do
      collectionName: 'testCollection'
      collectionConstructor: @Collection
      modelConstructor: @Model
      verbose: false
      resolve!

describe 'model', ->
  
  before ->
    @x = new @Model test: 33, args: { bla: 1 }
    
  specify 'create', -> new p (resolve,reject) ~>
    @x.save().then ~> 
      assert.ok it.attributes.id
      assert.deepEqual @x.attributes, it.attributes
      resolve!

  specify 'update', -> new p (resolve,reject) ~>
    @x.set test: 66
    @x.save()
    .then ~> 
      assert.equal it.attributes.test, 66
      assert.equal it.attributes, @x.attributes
      resolve!

  specify 'delete', -> new p (resolve,reject) ~>
    @x.destroy()
    .then -> resolve!

describe 'collection', ->
  
  before -> 
    @c = new @Collection()
    @c.fetch().then (ret) ->
      console.log "RET", ret
      console.log "RET", ret.models
      p.all ret.map (obj) ->
        console.log "REMOVEING",obj
        if obj? then obj.destroy!
      
    .then ~>
      p.map [
        new @Model test: 91, args: { x: 2 }
        new @Model test: 90, args: { x: 1 } ], (.save!)
        
  specify 'parametric fetch', ->
    @c.fetch(search: { test: 91 })
    .then (ret) ~>
      assert.equal ret?@@, @Collection
      assert.equal ret.length, 1
      assert.equal head(ret.models)@@, @Model
      assert.equal head(ret.models).get('args').x, 2
      
  specify 'update model', ->
    @c.fetch()
    .then (ret) ~> 
      assert.equal ret?@@, @c@@
      m = last(ret.models)
      m.set kaka: 39
      m.save()
      
    .then ~> 
      @c.fetch search: { kaka: 39 }
      .then (ret) ->
        assert.equal ret.length, 1

  specify 'fetch and delete', ->
    @c.fetch()
    .then (ret) ~> 
      assert.equal ret?@@, @c@@
      assert.equal ret.length, 2
      assert.equal head(ret.models)@@, @Model
      p.map ret.models, -> if it then it.destroy!

  specify 'check if clean', ->
    @c.fetch()
    .then (ret) ~> 
      assert.equal ret?@@, @c@@
      assert.equal ret.length, 0
