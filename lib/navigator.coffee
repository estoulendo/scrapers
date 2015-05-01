require = patchRequire global.require

utils = require 'utils'
casper = require 'casper'

class Navigator
  constructor: (casper, options) ->
    @casper = casper
    {
      # this is the first page that will be requested
      @startURL,
      # a CSS selector that identifies a link to the next page
      @nextPageSelector,
      # a CSS selector that identifies links
      @linksSelector,
      # an object that will parse each link
      @scraper,
    } = options

    @currentPage = 0
    @links = []

  onStart: (callback) ->
    @_onStart = callback

  onFinish: (callback) ->
    @_onFinish = callback

  execute: ->
    @casper
      .thenOpen(@startURL, @_start)
      .then(@_navigateThroughPages)
      .then(@_parseLinks)
      .then(@_finish)

  _start: =>
    @casper.log 'Started', 'info'
    @_onStart() if utils.isFunction(@_onStart)

  _finish: =>
    @casper.log('Done!', 'info')
    @_onFinish() if utils.isFunction(@_onFinish)

  _hasNextPage: =>
    @casper.visible @nextPageSelector

  _navigateThroughPages: =>
    @currentPage++
    length = @_pushLinks()

    @casper.log 'Scraping page ' + @currentPage, 'info'
    @casper.log 'Found ' + length + ' links', 'info'

    if @_hasNextPage()
      @casper.log 'Going to the next page', 'info'
      @casper.thenClick @nextPageSelector, @_navigateThroughPages
    else
      @casper.log 'No more pages left', 'info'

  _getPageLinks: (selector) ->
    __utils__.findAll(selector).map (e) ->
      e.href

  _pushLinks: =>
    utils
      .unique(@casper.evaluate(@_getPageLinks, @linksSelector))
      .map (href) =>
        @links.push href
      .length

  _parseLinks: =>
    @casper.log 'Scraping each link', 'info'

    utils.unique(@links).map (href) =>
      @scraper.parse(href)

module.exports = Navigator
