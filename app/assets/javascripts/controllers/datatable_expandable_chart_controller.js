import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datatable-expandable-chart"
export default class extends Controller {
  connect() {
    var self = this,
        ele = self.element
    $(ele).on('maximized.lte.cardwidget', function(evt) {
      var attempts = 0,
          maximized = false,
          initialHeight = ele.offsetHeight,
          lastHeight = initialHeight

      self.toggleChartDiv(ele)
      setTimeout(function tryAgain() {
        attempts += 1
        maximized = lastHeight > initialHeight && ele.offsetHeight == lastHeight
        if (attempts < 10 && !maximized) {
          lastHeight = ele.offsetHeight
          setTimeout(tryAgain, 50)
        } else {
          self.fireResize(ele)
        }
      }, 50)
    })

    $(ele).on('minimized.lte.cardwidget', function(evt) {
      var attempts = 0,
          minimized = false,
          initialHeight = ele.offsetHeight,
          lastHeight = initialHeight

      self.toggleChartDiv(ele)
      setTimeout(function tryAgain() {
        attempts += 1
        minimized = lastHeight < initialHeight && ele.offsetHeight == lastHeight
        if (attempts < 10 && !minimized) {
          lastHeight = ele.offsetHeight
          setTimeout(tryAgain, 50)
        } else {
          self.fireResize(ele)
        }
      }, 50)
    })
  }
    
  fireResize(ele) {
    this.toggleChartDiv(ele)
    var evt = document.createEvent('Event')
    evt.initEvent('resize', true, true)
    window.dispatchEvent(evt)
  }
  
  toggleChartDiv(ele) {
    var cardBody = ele.querySelector('.card-body'),
        chartDiv = cardBody.firstElementChild
    
    if (chartDiv.style.display == 'none') {
      chartDiv.style.display = 'block'
    } else {
      chartDiv.style.display = 'none'
    }
  }
}
