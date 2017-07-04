require! { 
  backbone4000: Backbone
  mongodb
  colors
}

export lego = backbone.Model.extend4000 do
  after: 'logger'
  init: (callback) ->

    sync = (method, model, options) ->
      console.log method: method, model: model, options: options
      
      switch method
        | 'create' => ...
        | 'read' => ...
        | 'update' => ...
        | 'delete' => ...
        | _ => throw new Error "unknwon backbone sync method (#{method})"
    
    @env.mongo = mongo = new mongodb.Db @settings.name, new mongodb.Server(@settings.host or 'localhost', @settings.port or 27017), safe: true
    @env.mongo.open (err, db) -> 
      data = colors.green('mongodb://' + @env.db.serverConfig.host + ":" + @env.db.serverConfig.port)
      if @legos.logger then @env.log "init db (#{colors.red(@settings.name)} at #{data})", {}, 'init','ok'

      callback undefined, data

