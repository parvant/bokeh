
find = (obj, name) ->
  if obj.get('name')? and obj.get('name') == name
    return obj
  if obj.get('children')?
    for c in obj.get('children')
      result = find(c, name)
      if result?
        return result
  if obj.get('renderers')?
    for r in obj.get('renderers')
      result = find(r, name)
      if result?
        return result
  return null


MAX_FREQ = 44100
SPECTROGRAM_LENGTH = 512
NGRAMS = 800
TILE_WIDTH = 500

class SpectrogramApp

  constructor: (layout) ->
    @request_data = _.throttle((=> @_request_data()), 20)
    @paused = false
    @gain = 1

    @spectrogram_plot = new SpectrogramPlot(find(layout, "spectrogram"))
    @signal_plot = new SimpleXYPlot(find(layout, "signal"))
    @power_plot = new SimpleXYPlot(find(layout, "spectrum"))
    #@eq_plot = new RadialHistogramPlot(find(layout, "eq"))

    @freq_slider = find(layout, "freq")
    @freq_slider.on("change:value", @update_freq)
    @gain_slider = find(layout, "gain")
    @gain_slider.on("change:value", @update_gain)

    setInterval((() => @request_data()), 400)

  update_freq: () =>
    freq = @freq_slider.get('value')
    @spectrogram_plot.set_yrange(0, freq)
    @power_plot.set_xrange(0, freq)

  update_gain: () =>
    @gain = @gain_slider.get('value')

  _request_data: () ->
    if @paused
      return

    $.ajax('http://localhost:5000/data', {
      type: 'GET'
      dataType: 'json'
      cache: false
      error: (jqXHR, textStatus, errorThrown) =>
        null
      success: (data, textStatus, jqXHR) =>
        @on_data(data)
      complete: (jqXHR, status) =>
        requestAnimationFrame(() => @request_data())
    })

  on_data: (data) ->
    signal = (x*@gain for x in data.signal)
    spectrum = (x*@gain for x in data.spectrum)
    power = (x*x for x in data.spectrum)

    @spectrogram_plot.update(spectrum)

    t = (i for i in [0...signal.length])
    @signal_plot.update(t, signal)
    f = (i/signal.length*MAX_FREQ for i in [0...signal.length])
    @power_plot.update(f, spectrum)
    #@eq_plot.update(data.bins)

class SpectrogramPlot

  constructor: (@model) ->
    @source = @model.get('data_source')
    @cmap = new Bokeh.LinearColorMapper.Model({
      palette: Bokeh.Palettes.all_palettes["YlGnBu-9"], low: 0, high: 10
    })

    plot = @model.attributes.parent
    @y_range = plot.get('frame').get('y_ranges')[@model.get('y_range_name')]

    @num_images = Math.ceil(NGRAMS/TILE_WIDTH) + 3

    @image_width = TILE_WIDTH

    @images = new Array(@num_images)
    for i in [0..(@num_images-1)]
      @images[i] = new ArrayBuffer(SPECTROGRAM_LENGTH * @image_width * 4)

    @xs = new Array(@num_images)

    @col = 0

  update: (spectrum) ->
    buf = @cmap.v_map_screen(spectrum)

    for i in [0...@xs.length]
      @xs[i] += 1

    @col -= 1
    if @col == -1
      @col = @image_width - 1
      img = @images.pop()
      @images = [img].concat(@images[0..])
      @xs.pop()
      @xs = [1-@image_width].concat(@xs[0..])

    image32 = new Uint32Array(@images[0])
    buf32 = new Uint32Array(buf)

    for i in [0...SPECTROGRAM_LENGTH]
      image32[i*@image_width+@col] = buf32[i]

    @source.set('data', {image: @images, x: @xs})
    @source.trigger('change', @source)

  set_yrange: (y0, y1) ->
    @y_range.set({'start': y0, 'end' : y1})

class RadialHistogramPlot

  constructor: (@model) ->
    @source = @model.get('data_source')

  update: (bins) ->
    angle = 2*Math.PI/bins.length
    [inner, outer, start, end, alpha] = [[], [], [], [], []]
    for i in [0...bins.length]
      range = [0...(bins[i]/32+1)]
      inner = inner.concat(j+2 for j in range)
      outer = outer.concat(j+2.95 for j in range)
      start = start.concat((i+0.05) * angle for j in range)
      end   = end.concat((i+0.95) * angle for j in range)
      alpha = alpha.concat(1 - 0.08*j for j in range)

    @source.set('data', {
      inner_radius: inner, outer_radius: outer, start_angle: start, end_angle: end, fill_alpha: alpha
    })
    @source.trigger('change', @source)

class SimpleXYPlot

  constructor: (@model) ->
    @source = @model.get('data_source')
    plot = @model.attributes.parent
    @x_range = plot.get('frame').get('x_ranges')[@model.get('x_range_name')]

  update: (x, y) ->
    @source.set('data', {idx: x, y: y})
    @source.trigger('change', @source)

  set_xrange: (x0, x1) ->
    @x_range.set({'start': x0, 'end' : x1})

setup = () ->
  index = window.Bokeh.index
  if _.keys(index).length == 0
    console.log "Bokeh not loaded yet, waiting to set up SpectrogramApp..."
    setTimeout(setup, 200)
  else
    console.log "Bokeh loaded, starting SpectrogramApp"
    id = _.keys(index)[0]
    app = new SpectrogramApp(index[id].model)

setTimeout(setup, 200)
