# Copyright 2012 The Apache Software Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# ##core/form-fragment
#
define ["_", "core/spi", "core/events", "core/compat/tapestry"],
  (_, spi, events) ->

    SELECTOR = '[data-component-type="core/FormFragment"]'

    # This is mostly for compatibility with 5.3, which supported
    # a DOM event to ask a fragment to remove itself.  This makes less sense since
    # default animations were eliminated in 5.4.
    spi.onDocument events.formfragment.remove, SELECTOR, (event) ->
      this.remove()

    # When any form fires the prepareForSubmit event, check to see if
    # any form fragments are contained within, and give them a chance
    # to enabled/disable their hidden field.
    spi.onDocument events.form.prepareForSubmit, "form", (event) ->

      fragments = this.find SELECTOR

      _.each fragments, (frag) ->

        fragmentId = frag.getAttribute "id"

        hidden = frag.findFirst "input[type=hidden][data-for-fragment=#{fragmentId}]"

        # If found (e.g., not alwaysSubmit), then enable/disable the field.
        hidden && hidden.setAttribute "disabled", not frag.deepVisible()

    # Again, a DOM event to make the FormFragment visible or invisible; this is useful
    # because of the didShow/didHide events ... but we're really just seeing the evolution
    # from the old style (the FormFragment class as controller) to the new style (DOM events and
    # top-level event handlers).
    spi.onDocument events.formfragment.changeVisibility, SELECTOR, (event) ->
        makeVisible = event.memo.visible

        this[if makeVisible then "show" else "hide"]()

        this.trigger events.element[if makeVisible then "didShow" else "didHide"]

        return false

    # Initializes a trigger for a FormFragment
    #
    # * spec.triggerId - id of checkbox or radio button
    # * spec.fragmentId - id of FormFragment element
    # * spec.invert - (optional) if true, then checked trigger hides (not shows) the fragment
    linkTrigger = (spec) ->
      trigger = spi spec.triggerId
      invert = spec.invert or false

      update = ->
        checked = trigger.element.checked
        makeVisible = checked isnt invert

        (spi spec.fragmentId).trigger events.formfragment.changeVisibility,  visible: makeVisible

      if trigger.element.type is "radio"
        spi.on trigger.element.form, "click", update
      else
        trigger.on "click", update

    { linkTrigger }