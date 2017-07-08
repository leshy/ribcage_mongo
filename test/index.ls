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
    @Model =  Backbone.Model.extend4000({})
    @Collection = Backbone.Collection.extend4000 do
      name: 'testCollection'
      model: @Model

    @Collection::sync = @Model::sync = env.mongo.sync do
      collectionName: 'testCollection'
      collectionConstructor: @Collection
      modelConstructor: @Model
      verbose: true
      resolve!

describe 'model', ->
  
  before ->
    @x = new @Model test: 33, args: { bla: 1 }
    
  specify 'create', -> new p (resolve,reject) ~>
    @x.save().then ~> 
      assert.ok it.id
      assert.deepEqual @x.attributes, it
      resolve!

  specify 'update', -> new p (resolve,reject) ~>
    @x.set test: 66
    @x.save()
    .then ~> 
      assert.equal it.test, 66
      assert.equal it, @x.attributes
      resolve!

  specify 'delete', -> new p (resolve,reject) ~>
    @x.destroy()
    .then -> resolve!

describe 'collection', ->
  before ->
    @c = new @Collection()
    @c.fetch()
    .then (ret) -> p.map ret, (.destroy!)
    .then ~> 
      p.map [
        new @Model test: 91, args: { collection: 2 }
        new @Model test: 90, args: { collection: 1 } ], -> it.save!
      
  specify 'fetch', ->
    @c.fetch()
    .then (ret) ~> 
      assert.equal ret?@@, Array
      assert.equal ret.length, 2
      assert.equal head ret@@ is @Mode

    
      

  specify 'save', ->
    @c.fetch()
    .then (ret) ~> 
      assert.equal ret?@@, Array
      m = last(ret)
      m.set kaka: 39
      m.save()
    .then ->
      assert it.kaka, 39

            
      

      

    
