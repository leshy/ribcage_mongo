require! {
  leshdash: { head, map, each }
  backbone4000: Backbone
  bluebird: p
  mongodb: { ObjectId }
  
  mongodb
  colors
}

export lego = Backbone.Model.extend4000 do
  after: 'logger'
  init: (callback) ->
    @env.mongo = mongo = new mongodb.Db @settings.name, new mongodb.Server(@settings.host or 'localhost', @settings.port or 27017), safe: true

    @env.mongo.open (err, db) ~> 
      data = colors.green('mongodb://' + @env.mongo.serverConfig.host + ":" + @env.mongo.serverConfig.port)
      if @legos.logger then @env.log "init db (#{colors.red(@settings.name)} at #{data})", {}, module: 'mongo', init: true, ok: true

      callback undefined, data

    translateOut = (obj) ->
      if obj.id
        id = obj.id
        delete obj.id
        obj <<< _id: new ObjectId(id)
      else obj

    translateIn = (obj) ->
      if obj._id
        id = obj._id
        delete obj._id
        obj <<< id: String(id)
      else obj

    # backbone sync implementation
    mongo.sync = ({collectionName, modelConstructor, collectionConstructor, verbose}) ->
      
      collection = mongo.collection collectionName
      
      (method, model, options) ->
        
        if verbose then console.log "SYNC", collectionName, method: method, options: options, model: model.toJSON()
        
        switch method
          | 'create' =>
            collection.insert model.toJSON!
            .then ->
              model.attributes <<< translateIn head it.ops
              model
            
          | 'read' =>
            switch model?@@
           
              | modelConstructor =>
                collection.findOne( _id: model.get('id')).then ->
                  model.attributes <<< it
                
              | (collectionConstructor or false) =>
                collection.find( options.search or {}).toArray().then ->
                  model.reset!
                  map it, (entry) -> model.add new modelConstructor translateIn entry
                  model
                    
              | _ =>
                throw new Error "wat"
                
          | 'update' =>
            collection.update { "_id": ObjectId(model.get('id')) }, { '$set': model.changed }
            .then ({ result }) -> new p (resolve,reject) ~>
              if result.ok isnt 1 or result.nModified isnt 1 then return reject new Error "update failed"
              resolve model
            
          | 'delete' =>
            collection.remove { "_id": ObjectId(model.get('id')) }
            .then -> true

          | _ => throw new Error "unknwon backbone sync method (#{method})"
