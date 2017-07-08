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
      modelConstructor: @Model
      collectionConstructor: @Collection
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
      
      # collection = new Collection()
      # x.save()
      # .then ->
      #   console.log x.attributes
      #   x.set test: 66
      #   x.save()
      #   .then ->
      #     x.fetch()
      #     .then ->
      #      console.log "MODEL READ",it
      #      collection.fetch()
      #      .then ->
      #         x.destroy()
      #         .then ->
      #           console.log "destroy", it
      #           resolve!
      

      

    
