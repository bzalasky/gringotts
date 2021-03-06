define (require) ->
  Chaplin = require 'chaplin'
  helper = require 'lib/mixin-helper'
  Paginated = require 'mixins/models/paginated'
  SyncKey = require 'mixins/models/sync-key'
  ForcedReset = require 'mixins/models/forced-reset'
  Queryable = require 'mixins/models/queryable'

  class MockPaginatedCollection extends Paginated Chaplin.Collection
    syncKey: 'someItems'
    urlRoot: '/test'

  describe 'Paginated mixin', ->
    sandbox = null
    collection = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: yes
      collection = new MockPaginatedCollection()

    afterEach ->
      sandbox.restore()
      collection.dispose()

    it 'should be instantiated', ->
      expect(collection).to.be.instanceOf MockPaginatedCollection

    it 'should have proper mixins applied', ->
      expect(helper.instanceWithMixin collection, Queryable).to.be.true
      expect(helper.instanceWithMixin collection, SyncKey).to.be.true
      expect(helper.instanceWithMixin collection, ForcedReset).to.be.true

    context 'fetching', ->
      infinite = null
      response = null

      beforeEach ->
        collection.count = 500
        collection.infinite = infinite
        collection.fetch()
        sandbox.server.respondWith response
        sandbox.server.respond()

      context 'on done', ->
        before ->
          response = [200, {}, JSON.stringify {
            count: 3
            someItems: [{}, {}, {}]
            next_page_id: 555
          }]

        after ->
          response = null

        it 'should query the server with the default query params', ->
          request = _.last sandbox.server.requests
          _.each ['page=1', 'per_page=30'], (i) ->
            expect(request.url).to.contain i

        it 'should parse response correctly', ->
          expect(collection.count).to.equal 3
          expect(collection.length).to.equal 3
          expect(collection.nextPageId).to.be.undefined

        context 'when pagination is infinite', ->
          before ->
            infinite = true

          after ->
            infinite = false

          it 'should read next page id', ->
            expect(collection.nextPageId).to.equal 555

      context 'on fail', ->
        before ->
          response = [500, {}, JSON.stringify {}]

        after ->
          response = null

        it 'should reset count to 0', ->
          expect(collection.count).to.equal 0
