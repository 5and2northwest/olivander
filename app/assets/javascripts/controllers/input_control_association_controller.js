import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="input-control-association"
export default class extends Controller {
  connect() {
    var self = this,
        el = self.element;

    if (el.dataset.forceSelect2 || !$(el).hasClass("select2-hidden-accessible")) {
      $(el).select2({
        dropdownParent: $(el).parent(),
        minimumInputLength: el.dataset.minimumInputLength || 0,
        tags: el.dataset.taggable == 'true',
        createTag: function (tag) {
          return {
              id: tag.term,
              text: tag.term,
              isNew : true
          };
        },
        ajax: {
          url: el.dataset.collectionPath,
          delay: 250,
          dataType: 'json',
          data: function(params) {
            var hash = {
              term: params.term,
              _type: params._type,
            }

            if (el.dataset.tagParentId) {
              hash[el.dataset.tagParentSearch] = el.dataset.tagParentId
            }

            return hash;
          },
          processResults: function(data) {
            return { results: data.map(function(map) {
              return {
                id: map.id,
                text: map.text || map.name || map.description,
                children: map.children
              };
            }) };
          }
        }
      }).on('select2:select', function (e) {
        let tag = e.params.data;
        if (tag.isNew === true)
        {
          let csrfToken = document.querySelector("[name='csrf-token']").content,
              data = new FormData()
          data.append("authenticity_token", document.querySelector('meta[name="csrf-token"]').content)
          data.append(el.dataset.tagFieldName, tag.text)
          data.append(el.dataset.tagParentField, el.dataset.tagParentId)
          fetch(el.dataset.collectionPath, {
            method: 'POST',
            headers: {
              "X-CSRF-Token": csrfToken,
              Accept: "application/json"
            },
            body: data
          })
          .then(r => r.json())
          .then(function(json) {
            $(el).find(`option[value='${tag.id}']`).each(function(idx, opt) {
              opt.value = json.id
            })
            $(el).select2().trigger('change')
            return true
          })
        }
      })
    }
  }
}
