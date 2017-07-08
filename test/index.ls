require! {
  colors  
  assert
  mongodb: { ObjectId }
  leshdash: { each, last, head, rpad, lazy, union, assign, omit, map, curry, times, keys, first, wait, head, pwait, wait, mapValues, reverse, reduce, filter }
  bluebird: p
  ribcage: { init }
  backbone4000: Backbone
}

describe 'root', ->

  specify 'init', -> new p (resolve,reject) ~>
    env = do
      settings:
        module:
          mongo:
            name: 'test'
    
    init env, (err,env) ->
      
      ModelSync =  Backbone.Model.extend4000({})
      
      ModelCollection = Backbone.Collection.extend4000 do
        name: 'task'
        model: ModelSync

      ModelCollection::sync = ModelSync::sync = env.mongo.sync do
        collectionName: 'task'
        modelConstructor: ModelSync
        collectionConstructor: ModelCollection
        verbose: true

      collection = new ModelCollection()
      x = new ModelSync test: 33, args: { bla: 1 }
      x.save()
      .then ->
        console.log x.attributes
        x.set test: 66
        x.save()
        .then ->
          x.fetch()
          .then ->
           console.log "MODEL READ",it
           collection.fetch()
           .then ->
              x.destroy()
              .then ->
                console.log "destroy", it
                resolve!
      

      

    
