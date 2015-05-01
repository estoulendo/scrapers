fs = require 'fs'
utils = require 'utils'
Navigator = require '../lib/navigator'

class DummyScraper
  constructor: -> @urls = []
  parse: (url) -> @urls.push url

casper.test.begin 'Navigator tests', 3, (test) ->
  expectedLinks = [
    'file://%s/tests/site/book1.html'
    'file://%s/tests/site/book2.html'
    'file://%s/tests/site/book3.html'
    'file://%s/tests/site/book4.html'
    'file://%s/tests/site/book5.html'
    'file://%s/tests/site/book6.html'
    'file://%s/tests/site/book7.html'
  ].map (link) -> utils.format(link, fs.workingDirectory)

  startURL = 'file://' + fs.workingDirectory + '/tests/site/index.html'
  scraper = new DummyScraper

  navigator = new Navigator(casper, {
    startURL: startURL
    scraper: scraper
    nextPageSelector: '.next a'
    linksSelector: '.books a'
  })

  navigator.onStart ->
    test.assertEqual(casper.getCurrentUrl(), startURL,
      'calls onStart with the start url as current page')

  navigator.onFinish ->
    test.assertEqual(scraper.urls.length, 7, 'must return all books links')
    test.assertEqual(scraper.urls, expectedLinks,
      'must not include repeated links')

  casper.start()

  navigator.execute()

  casper.run ->
    test.done()
