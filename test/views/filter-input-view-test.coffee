define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  FilterInputView = require 'views/filter-input-view'

  describe 'FilterInputView', ->
    sandbox = null
    collection = null
    groupSource = null
    view = null

    beforeEach ->
      sandbox = sinon.sandbox.create()
      collection = new Chaplin.Collection [
        new Chaplin.Model
          groupId: 'group1'
          groupName: 'Group One'
          id: 'gp1item2'
          name: 'G1 Item Two'
        new Chaplin.Model
          groupId: 'group2'
          groupName: 'Group Two'
          id: 'gp2item1'
          name: 'G2 Item One'
        new Chaplin.Model
          groupId: 'group2'
          groupName: 'Group Two'
          id: 'gp2item2'
          name: 'G2 Item Two'
      ]
      groupSource = new Chaplin.Collection [
        new Chaplin.Model
          id: 'group1'
          name: 'Group One'
          description: 'One Description'
          children: new Chaplin.Collection [
            new Chaplin.Model id: 'gp1item1', name: 'G1 Item One'
            new Chaplin.Model id: 'gp1item2', name: 'G1 Item Two'
            new Chaplin.Model id: 'gp1item3', name: 'G1 Item Three'
          ]
        new Chaplin.Model
          id: 'group2'
          name: 'Group Two'
          description: 'Two Description'
          children: new Chaplin.Collection [
            new Chaplin.Model id: 'gp2item1', name: 'G2 Item One'
            new Chaplin.Model id: 'gp2item2', name: 'G2 Item Two'
          ]
      ]
      sandbox.stub _, 'debounce', (fn) -> fn
      view = new FilterInputView {
        collection
        groupSource
        placeholder: 'Filter items by...'
      }
      $('body').append view.$el

    afterEach ->
      sandbox.restore()
      view.$el.remove()
      view.dispose()
      collection.dispose()
      groupSource.dispose()

    it 'should have proper classes applied', ->
      expect(view.$el).to.have.class 'form-control'
      expect(view.$el).to.not.have.class 'focus'

    it 'should have placeholder set', ->
      expect(view.$ 'input').to.have.attr 'placeholder', 'Filter items by...'

    it 'should have dropdowns collapsed', ->
      expect(view.$ '.dropdown').to.not.have.class 'open'

    it 'should not render group label', ->
      expect(view.$ '.selected-group').to.have.text ''

    it 'should render selected items', ->
      $selectedItems = view.$ '.selected-item'
      expect($selectedItems).to.have.length 3
      $selectedItems.each (i, el) ->
        model = collection.models[i]
        $el = $ el
        expect($el.find '.item-group').to.have.text model.get 'groupName'
        expect($el.find '.item-name').to.have.text model.get 'name'

    context 'on selected item remove click', ->
      beforeEach ->
        view.$('.selected-item .remove-button').first().click()

      it 'should remove item from collection', ->
        expect(collection.length).to.equal 2

      it 'should remove item from control', ->
        expect(view.$ '.selected-item').to.have.length 2

    context 'on remove all click', ->
      beforeEach ->
        view.$('.remove-all-button').click()

      it 'should remove all items from collection', ->
        expect(collection.length).to.equal 0

      it 'should remove all items from control', ->
        expect(view.$ '.selected-item').to.not.exist

    expectInputFocused = ->
      it 'should have input focused', ->
        expect(view.$('input')[0] is document.activeElement).to.be.true

    expectOpenGroupsDropdown = ->
      it 'should show dropdown', ->
        expect(view.$ '.dropdown').to.have.class 'open'

      it 'should have groups dropdown visible', ->
        expect(view.$ '.dropdown-groups').to.not.have.class 'hidden'
        expect(view.$ '.dropdown-items').to.have.class 'hidden'

      it 'should have input empty', ->
        expect(view.$ 'input').to.have.text ''

      it 'should add focus to the root element', ->
        expect(view.$el).to.have.class 'focus'

    expectDefaultGroupsInDropdown = ->
      it 'should render groups dropdown', ->
        $groupItems = view.$ '.dropdown-groups a'
        expect($groupItems).to.have.length 2
        $groupItems.each (i, el) ->
          model = groupSource.models[i]
          $el = $ el
          expect($el.find '.item-name').to.have.text model.get 'name'
          expect($el.find '.item-description').to
            .have.text model.get 'description'

    expectEmptyDropdown = (dropdown) ->
      it "should render empty #{dropdown} dropdown", ->
        view.$(".dropdown-#{dropdown} li.fade").each (i, el) ->
          expect($ el).to.have.css 'display', 'none'
        expect(view.$ ".dropdown-#{dropdown} li.empty").to.not
          .have.css 'display', 'none'
        expect(view.$ ".dropdown-#{dropdown} li.loading").to
          .have.css 'display', 'none'

    expectOpenItemsDropdown = ->
      it 'should show dropdown', ->
        expect(view.$ '.dropdown').to.have.class 'open'

      it 'should have items dropdown visible', ->
        expect(view.$ '.dropdown-groups').to.have.class 'hidden'
        expect(view.$ '.dropdown-items').to.not.have.class 'hidden'

      it 'should have input empty', ->
        expect(view.$ 'input').to.have.text ''

    expectDefaultItemsDropdown = ->
      it 'should render group label', ->
        expect(view.$ '.selected-group').to.have.text 'Group One'

      it 'should render items dropdown', ->
        $items = view.$ '.dropdown-items a'
        expect($items).to.have.length 2
        expect($items.first().find '.item-name').to
          .have.text 'G1 Item One'
        expect($items.last().find '.item-name').to
          .have.text 'G1 Item Three'

    expectClosedDropdowns = ->
      it 'should hide dropdown', ->
        expect(view.$ '.dropdown').to.not.have.class 'open'

      it 'should remove focus from the root element', ->
        expect(view.$el).to.not.have.class 'focus'

    expectItemSelected = (groupName, itemName) ->
      it 'should render the item in selection', ->
        $lastSelectedItem = view.$('.selected-item').last()
        expect($lastSelectedItem.find '.item-group').to.have.text groupName
        expect($lastSelectedItem.find '.item-name').to.have.text itemName

    context 'on whitespace click', ->
      beforeEach ->
        view.$el.click()

      expectOpenGroupsDropdown()

    context 'on input click', ->
      beforeEach ->
        view.$('input').click()

      expectOpenGroupsDropdown()
      expectDefaultGroupsInDropdown()

      context 'on first group item click', ->
        beforeEach ->
          view.$('.dropdown-groups a').first().click()

        expectOpenItemsDropdown()
        expectDefaultItemsDropdown()

        context 'on last item click', ->
          beforeEach ->
            view.$('.dropdown-items a').last().click()

          expectClosedDropdowns()
          expectItemSelected 'Group One', 'G1 Item Three'

          it 'should add item model into collection', ->
            expect(collection.last().attributes).to.eql {
              groupId: 'group1'
              groupName: 'Group One'
              id: 'gp1item3'
              name: 'G1 Item Three'
            }

      context 'on last group item click', ->
        beforeEach ->
          view.$('.dropdown-groups a').last().click()

        it 'should render group label', ->
          expect(view.$ '.selected-group').to.have.text 'Group Two'

        expectEmptyDropdown 'items'

    context 'on input enter', ->
      beforeEach ->
        view.$('input').focus().trigger $.Event 'keydown',
          which: utils.keys.ENTER

      expectOpenGroupsDropdown()

      context 'on type text', ->
        text = null

        beforeEach ->
          view.$('input').val(text).trigger $.Event 'keyup'

        context 'existing group name', ->
          before ->
            text = 'one'

          getVisibleItems = (dropdown) ->
            items = _.filter view.$(".dropdown-#{dropdown} li.fade"), (el) ->
              $(el).css('display') is 'list-item'

          it 'should filter groups dropdown', ->
            groupItems = getVisibleItems 'groups'
            expect(groupItems).to.have.length 1
            $first = $ _.first groupItems
            expect($first.find '.item-name').to.have.text 'Group One'

          context 'on enter key press when 1 group in dropdown', ->
            beforeEach ->
              view.$('input').trigger $.Event 'keydown',
                which: utils.keys.ENTER

              expectOpenItemsDropdown()
              expectInputFocused()

            it 'should select group', ->
              expect(view.$ '.selected-group').to.have.text 'Group One'

            context 'on type existing item text', ->
              beforeEach ->
                view.$('input').val('thre').trigger 'keyup'

              it 'should filter items dropdown', ->
                items = getVisibleItems 'items'
                expect(items).to.have.length 1
                $first = $ _.first items
                expect($first.find '.item-name').to.have.text 'G1 Item Three'

              context 'on enter key press when 1 item in dropdown', ->
                beforeEach ->
                  view.$('input').trigger $.Event 'keydown',
                    which: utils.keys.ENTER

                expectOpenGroupsDropdown()
                expectItemSelected 'Group One', 'G1 Item Three'
                expectInputFocused()

            context 'on type random text', ->
              beforeEach ->
                view.$('input').val('qwerty').trigger 'keyup'

              expectEmptyDropdown 'items'

              context 'on esc key press', ->
                beforeEach ->
                  view.$('input').trigger $.Event 'keydown',
                    which: utils.keys.ESC

                it 'should clear selected group', ->
                  expect(view.$ '.selected-group').to.have.text ''

                expectOpenGroupsDropdown()
                expectDefaultGroupsInDropdown()
                expectInputFocused()

          context 'random text', ->
            before ->
              text = 'asdfgh'

            expectEmptyDropdown 'groups'

            context 'on delete text', ->
              beforeEach ->
                view.$('input').val('').trigger $.Event 'keydown',
                  which: utils.keys.DELETE

              expectOpenGroupsDropdown()
              expectDefaultGroupsInDropdown()
              expectInputFocused()

      context 'on down key press', ->
        beforeEach ->
          view.$('input').trigger $.Event 'keydown',
            which: utils.keys.DOWN

        it 'should focus dropdown first group', ->
          $first = view.$('.dropdown-groups a').first()
          expect($first.find '.item-name').to.have.text 'Group One'
          expect($first[0] is document.activeElement).to.be.true

        context 'on click input back', ->
          beforeEach ->
            view.$('input').click()

          expectOpenGroupsDropdown()

        context 'on enter key press', ->
          beforeEach ->
            $(document.activeElement)
              .trigger($.Event 'keydown', which: utils.keys.ENTER)
              .click()

          expectDefaultItemsDropdown()

          context 'on down key press', ->
            beforeEach ->
              view.$('input').trigger $.Event 'keydown',
                which: utils.keys.DOWN

            it 'should focus dropdown first item', ->
              $first = view.$('.dropdown-items a').first()
              expect($first.find '.item-name').to.have.text 'G1 Item One'
              expect($first[0] is document.activeElement).to.be.true

            context 'on enter key press', ->
              beforeEach ->
                $(document.activeElement)
                  .trigger($.Event 'keydown', which: utils.keys.ENTER)
                  .click()

              expectOpenGroupsDropdown()
              expectItemSelected 'Group One', 'G1 Item One'
              expectInputFocused()

      context 'on up key press', ->
        beforeEach ->
          view.$('input').trigger $.Event 'keydown',
            which: utils.keys.UP

        it 'should focus dropdown last item', ->
          $last = view.$('.dropdown-groups a').last()
          expect($last.find '.item-name').to.have.text 'Group Two'
          expect($last[0] is document.activeElement).to.be.true

      context 'on click elsewhere', ->
        beforeEach ->
          $(document).trigger 'click.bs.dropdown.data-api'

        it 'should remove focus from the root element', ->
          expect(view.$el).to.not.have.class 'focus'
