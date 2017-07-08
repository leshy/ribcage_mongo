require! {
  leshdash: { head, map, each }
  backbone4000: Backbone
  mongodb
  bluebird: p
  mongodb: { ObjectId }
  colors
}

export lego = Backbone.Model.extend4000 do
  after: 'logger'
  init: (callback) ->

    @env.mongo = mongo = new mongodb.Db @settings.name, new mongodb.Server(@settings.host or 'localhost', @settings.port or 27017), safe: true

    @env.mongo.open (err, db) ~> 
      data = colors.green('mongodb://' + @env.mongo.serverConfig.host + ":" + @env.mongo.serverConfig.port)
      if @legos.logger then @env.log "init db (#{colors.red(@settings.name)} at #{data})", {}, 'init','ok'

      callback undefined, data

    translateOut = (obj) ->
      if obj.id
        id = obj.id
        delete obj.id
        obj <<< _id: id
      else obj

    translateIn = (obj) ->
      if obj._id
        id = obj._id
        delete obj._id
        obj <<< id: id
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
            
          | 'read' =>
            switch model?@@
           
              | modelConstructor =>
                collection.findOne( _id: model.get('id')).then ->
                  model.attributes <<< it
                
              | (collectionConstructor or false) =>
                model.reset!
                collection.find( options.search or {}).toArray().then ->
                  map it, (entry) -> model.add new modelConstructor translateIn entry
                    
              | _ => throw new Error "wat"
                
          
          | 'update' =>
            collection.update { "_id": model.get('id') }, { '$set': model.changed }
            .then ({ result }) -> new p (resolve,reject) ~>
              if result.ok isnt 1 or result.nModified isnt 1 then return reject new Error "update failed"
              resolve model.attributes
            
          | 'delete' =>
            collection.remove { "_id": model.get('id') }
            .then -> true

          | _ => throw new Error "unknwon backbone sync method (#{method})"
